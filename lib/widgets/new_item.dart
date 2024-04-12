import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; //this http could be anyname and it is just a name of an object in which the bundle is saved
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = "";
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!
          .save(); //when this line exicutes a special function will be exicuted in all the textfield areas and that is onSaved function
      setState(() {
        _isSending = true;
      });
      final url = Uri.https("flutter-prep-277c9-default-rtdb.firebaseio.com",
          "shopping-list.json");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(
          {
            "name": _enteredName,
            "quantity": _enteredQuantity,
            "category": _selectedCategory.title,
          },
        ),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);
      print(response
          .body); //you will see an output like "name:xyz123" here this name is not the name of the item. dont get confused, this "name" is the name given by firebase to the response
      print(
          response.statusCode); //status code returns the status of the request

      if (!context.mounted) {
        //while check weather the current context is the same as the previos one before awaiting or not (for example if there was a situation where some data was to be deleted and the request and response was not yet completed then would have been wrong if you got directly forward and run the code with the incomplete context)
        return;
      }

      Navigator.of(context).pop(
        //very very very important to understand, when you pop this screen and navigate back to the last screen this will return back a value and there will be the stored in the variable(if used) which was assigned the value while navigating to this screen
        GroceryItem(
          id: responseData["name"],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text("Name"),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return "Must be between 1 to 50 characters.";
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Quantity"),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Must be a valid positive number.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(
                            value!); // difference between parse and try parse is that parse throws an error when it fails to convert the string to a number while try parse returns null
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories
                            .entries) //categories is a map and using for loop we cannot itereate in a map so just use entries keyword
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text("Reset"),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text("Add Item"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
