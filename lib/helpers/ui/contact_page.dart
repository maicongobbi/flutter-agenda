import 'dart:io';

import 'package:agenda/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

//parametro opcional
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage>
    with SingleTickerProviderStateMixin {
  Contact _editedContact;
  bool _userEdited = false;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = new Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      nameController.text = _editedContact.name;
      emailController.text = _editedContact.email;
      phoneController.text = _editedContact.phone;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact.name ?? "Novo contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact.name != null && _editedContact.name.isNotEmpty) {
              //remove a tela atual e volta para a anterior
              Navigator.pop(context, _editedContact);
            } else {
              //se o nome for vazio ele vai dar foco na parada vazia do nome
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _editedContact.img != null
                              ? FileImage(File(_editedContact.img))
                              : AssetImage("images/person.png"),
                          fit: BoxFit.cover)),
                ),
                onTap: () {
                  ImagePicker.pickImage(source: ImageSource.camera)
                      .then((file) {
                    if (file == null) return;
                    setState(() {
                      _editedContact.img = file.path;
                    });
                  });
                },
              ),
              TextField(
                controller: nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(
                  labelText: "Nome",
                ),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                  ),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact.email = text;
                  },
                  keyboardType: TextInputType.emailAddress),
              TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: "Phone",
                  ),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact.phone = text;
                  },
                  keyboardType: TextInputType.phone)
            ],
          ),
        ),
      ),
      onWillPop: _requestPop,
    );
  }

  Future<bool> _requestPop() {
    print('NO REQ POP \n\n\n\n');
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("descartar alterações?"),
              content: Text("Se sair vc perderá as alterações"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancelar")),
                FlatButton(
                    onPressed: () {
                      //saindo do dialog
                      Navigator.pop(context);
                      //saindo do contact
                      Navigator.pop(context);
                    },
                    child: Text("Sim"))
              ],
            );
          });
      print(1111);
      return Future.value(false);
    } else {
      print(2222222222222);
      return Future.value(true);
    }
  }
}
