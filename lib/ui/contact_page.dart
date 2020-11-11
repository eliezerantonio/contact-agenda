import 'dart:io';

import 'package:agenda/helpers/contact_helpers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  ContactPage({this.contact});

  final Contact contact;

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact _editedContact;
  bool _userEdited = false;

  //Controller
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editedContact.name ?? "Novo Contacto"),
          backgroundColor: Colors.indigo,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              GestureDetector(

                onTap: (){
                  // ignore: deprecated_member_use
                  ImagePicker.pickImage(source: ImageSource.gallery).then(
                          (file) {
                            if(file==null) return;
                          setState(() {
                            _editedContact.img=file.path;
                          });
                          });
                },
                child: Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _editedContact.img != null
                          ? FileImage(File(_editedContact.img))
                          : AssetImage("assets/person.png"),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(
                  labelText: "Nome",
                  border: OutlineInputBorder(),
                ),
                onChanged: (text) {
                  setState(() {
                    _userEdited = true;
                    _editedContact.name = text;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "E-mail",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    setState(() {
                      _userEdited = true;
                      _editedContact.email = text;
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Phone"),
                onChanged: (text) {
                  setState(() {
                    _userEdited = true;
                    _editedContact.phone = text;
                  });
                },
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          backgroundColor: Colors.indigo,
          onPressed: () {
            if (_editedContact.name != null) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alteracoes?"),
              content: Text("Se sair as alteracoes serao perdidas"),
              actions: [
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
