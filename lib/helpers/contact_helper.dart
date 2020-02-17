import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// declarando o nome das colunas

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

///não terá varias instancias e apenas um é singleton

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  /// quando instancia o helper ele chama o contruotr interno qu não pode ser chamado de nenhum outro lugar
  /// a fabrica retorna o ob, senfdo que qdo eu der o .instance já o tenho em maos

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  /// declarando o banco de dados
  Database _db;

  ///inicializando o bc

  Future<Database> get db async {
    if (_db != null)
      return _db;
    else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();

    ///pega o caminho da pasta + o nome do banco para ficar completo
    final path = join(databasePath, "contacts.db");
    /**
     * cria a atabela apeas na primeira vez
     */
    return openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT," +
              "$phoneColumn TEXT, $imgColumn TEXT )");
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    print(contact);
    print("\n\n\n\n\n\n\n");

    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  Future<List<Contact>> getAllContact() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> lista = List();
    for (Map map in listMap) {
      lista.add(Contact.fromMap(map));
    }
    return lista;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db;
    return dbContact.close();
  }
} //end of class

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  ///retornnando do banco

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  /// mandando para o banco

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
    return "Contact (id: $id, name: $name, phone: $phone, email: $email, img: $img";
  }
}
