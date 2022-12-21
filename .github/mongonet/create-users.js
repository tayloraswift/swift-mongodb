db = connect('mongodb://localhost/admin');
db.createUser({user: "root", pwd: "80085", roles: ["root"]});
