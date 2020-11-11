import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  //BD
  Database _db;

  Future<Database> get getDb async {
    if(_db != null){
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

//INICIALIZAR DB
  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contactsNew.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
              "$phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async {

    print(contact.toMap());
    Database dbContact = await getDb;
    contact.id = await dbContact.insert(contactTable, contact.toMap()
       );
    return contact;
  }

  //OBETER
  Future<Contact> getContact(int id) async {
    Database dbContact = await getDb;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn= ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  //DELETE
  Future<int> deleteContact(int id) async {
    Database dbContact = await getDb;
    return await dbContact
        .delete(contactTable, where: "$idColumn= ?", whereArgs: [id]);
  }

  //UPDATE
  updateContact(Contact contact) async {
    Database dbContact = await getDb;
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn= ?", whereArgs: [contact.id]);
  } //BUSCAR TODOS

  Future<List> getAllContacts() async {
    Database dbContact = await getDb;
    List listMap = await dbContact.rawQuery("SELECT * FROM "
        "$contactTable");
    //transformando mapa em contacto
    List<Contact> listContact = List();

    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  //GET NUMBER
  Future<int> getNumber() async {
    Database dbContact = await getDb;

    return Sqflite.firstIntValue(
        await dbContact.rawQuery(("SELECT COUNT(*) FROM $contactTable")));
  }

  close() async {
    Database dbContact = await getDb;
    dbContact.close();
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  //para mapa
  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  //para contacto
  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };

    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return 'Contact{id: $id, name: $name, email: $email, phone: $phone, img: $img}';
  }
}
