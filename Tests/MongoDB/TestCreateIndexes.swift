import BSONDecoding
import BSONEncoding
import MongoDB
import Testing

func TestCreateIndexes(_ tests:TestGroup, bootstrap:Mongo.DriverBootstrap) async
{
    guard let tests:TestGroup = tests / "create-indexes"
    else
    {
        return
    }

    await bootstrap.withTemporaryDatabase(named: "create-indexes-tests", tests: tests)
    {
        (pool:Mongo.SessionPool, database:Mongo.Database) in

        let session:Mongo.Session = try await .init(from: pool)

        if  let tests:TestGroup = tests / "products-example"
        {
            struct Product:Equatable, Hashable, BSONDocumentDecodable, BSONDocumentEncodable
            {
                let item:Int
                let manufacturer:String
                let supplier:String
                let model:String

                init(item:Int,
                    manufacturer:String,
                    supplier:String,
                    model:String)
                {
                    self.item = item
                    self.manufacturer = manufacturer
                    self.supplier = supplier
                    self.model = model
                }

                enum CodingKeys:String
                {
                    case item
                    case manufacturer
                    case supplier
                    case model
                }

                init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>)
                    throws
                {
                    self.init(item: try bson[.item].decode(),
                        manufacturer: try bson[.manufacturer].decode(),
                        supplier: try bson[.supplier].decode(),
                        model: try bson[.model].decode())
                }

                func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
                {
                    bson[.item] = self.item
                    bson[.manufacturer] = self.manufacturer
                    bson[.supplier] = self.supplier
                    bson[.model] = self.model
                }
            }

            let collection:Mongo.Collection = "inventory"

            await tests.do
            {
                let expected:Mongo.InsertResponse = .init(inserted: 6)
                let response:Mongo.InsertResponse = try await session.run(
                    command: Mongo.Insert.init(collection, encoding: [
                            .init(item: 0,
                                manufacturer: "Lilly Pulitzer",
                                supplier: "Wenzhou Lihui",
                                model: "Adler Mini Skirt"),
                            .init(item: 1,
                                manufacturer: "Lilly Pulitzer",
                                supplier: "Wenzhou Lihui",
                                model: "Paxton Sarong"),
                            .init(item: 2,
                                manufacturer: "Lilly Pulitzer",
                                supplier: "Promise One",
                                model: "Atley Ruffle Cover-up"),
                            .init(item: 3,
                                manufacturer: "Lilly Pulitzer",
                                supplier: "Promise One",
                                model: "Lawless Sleeveless Romper"),
                            .init(item: 0,
                                manufacturer: "Cider",
                                supplier: "Promise One",
                                model: "Floral Bell Sleeve Corset Mini Dress"),
                            .init(item: 1,
                                manufacturer: "Cider",
                                supplier: "Wenzhou Lihui",
                                model: "Glitter O-Ring Backless Halter Top"),
                        ] as [Product]),
                    against: database)

                tests.expect(response ==? expected)
            }
            await tests.do
            {
                let expected:Mongo.CreateIndexesResponse = .init(
                    createdCollectionAutomatically: false,
                    indexesBefore: 1,
                    indexesAfter: 3)
                let response:Mongo.CreateIndexesResponse = try await session.run(
                    command: Mongo.CreateIndexes.init(collection,
                        writeConcern: .majority,
                        indexes:
                        [
                            .init
                            {
                                $0[.unique] = true
                                $0[.name] = "item_manufacturer_model"
                                $0[.key] = .init
                                {
                                    $0["item"] = (+)
                                    $0["manufacturer"] = (+)
                                    $0["model"] = (+)
                                }
                            },
                            .init
                            {
                                $0[.unique] = true
                                $0[.name] = "item_supplier_model"
                                $0[.key] = .init
                                {
                                    $0["item"] = (+)
                                    $0["supplier"] = (+)
                                    $0["model"] = (+)
                                }
                            },
                        ]),
                    against: database)

                tests.expect(response ==? expected)
            }
        }
    }
}
