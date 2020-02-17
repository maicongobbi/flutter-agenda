import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:agenda/helpers/contact_helper.dart';
import 'package:agenda/helpers/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = new ContactHelper();
//são o mesmo objeto
//  ContactHelper helper2 = new ContactHelper();
  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Contatos"),
          backgroundColor: Colors.red,
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton<OrderOptions>(
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                const PopupMenuItem<OrderOptions>(
                  child: Text("ordenar de A-Z"),
                  value: OrderOptions.orderaz,
                ),
                const PopupMenuItem<OrderOptions>(
                  child: Text("ordenar de Z-A"),
                  value: OrderOptions.orderza,
                ),
              ],
              onSelected: _orderList,
            ),
          ]),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              //colocando a imagem redonda
              Container(
                width: 80,
                height: 80.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: contacts[index].img != null
                            ? FileImage(File(contacts[index].img))
                            : AssetImage("images/person.png"),
                            fit: BoxFit.cover)),
              ),

              Padding(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //se for null coloca vazio
                    Text(contacts[index].name ?? "",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(contacts[index].email ?? "",
                        style: TextStyle(fontSize: 18)),
                    Text(contacts[index].phone ?? "",
                        style: TextStyle(fontSize: 18)),
                  ],
                ),
                padding: EdgeInsets.only(left: 10),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showContactPage({Contact contact}) async {
    //rec contact é a resposta da pagina editar contato
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));
    print(recContact);
    print("\n\n\n\n\n\n\n\n **********************************");

    //editanco contato
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContact().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                          onPressed: () {
                            launch("tel:${contacts[index].phone}");
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Ligar",
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showContactPage(contact: contacts[index]);
                          },
                          child: Text(
                            "Editar",
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                          onPressed: () {
                            helper.deleteContact(contacts[index].id);
                            setState(() {
                              contacts.removeAt(index);
                              Navigator.pop(context);
                            });
                          },
                          child: Text(
                            "Excluir",
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          )),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  void _orderList(OrderOptions value) {
    switch (value) {
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
         return  a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;

      case OrderOptions.orderza:
           contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
      default:

    }
    //ao ser vazio ele já atualiz a view
    setState(() {
      
    });
  }
}
