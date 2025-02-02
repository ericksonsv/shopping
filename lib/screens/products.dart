import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
final myChannel = supabase.channel('my_channel');

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    _fetchProducts();
    _subscribeToRealtime();
    super.initState();
  }

  // Fetch all products
  Future<void> _fetchProducts() async {
    final response = await supabase.from('products').select('*').order('name', ascending: true);
    setState(() {
      products = List<Map<String, dynamic>>.from(response);
    });
  }

  // Subscribe to real-time changes
  void _subscribeToRealtime() {
    myChannel
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'products',
      callback: (payload) => _fetchProducts()
    )
    .subscribe();
  }

  // SHOW DIALOG TO ADD NEW PRODUCT
  void addProductDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add product'),
        content: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name
              TextFormField(
                controller: nameController,
              ),
              // Quantity
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
              )
            ],
          )
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel')
          ),
          OutlinedButton(
            onPressed: () async {
              await supabase.from('products').insert(
                {
                  'name': nameController.text.trim(),
                  'quantity': int.parse(quantityController.text.trim())
                }
              );
              nameController.clear();
              quantityController.clear();
              Navigator.pop(context);
            },
            child: Text('Add')
          )
        ],
      ),
    );
  }

  // SHOW DIALOG TO EDIT NEW PRODUCT
  void editProductDialog(int index) {
    final product = products[index];
    nameController.text = product['name'];
    quantityController.text = product['quantity'].toString();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit product'),
        content: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name
              TextFormField(
                controller: nameController,
              ),
              // Quantity
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
              )
            ],
          )
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel')
          ),
          OutlinedButton(
            onPressed: () async {
              await supabase.from('products').update(
                {
                  'name': nameController.text.trim(),
                  'quantity': int.parse(quantityController.text.trim())
                }
              ).eq('id', product['id']);
              nameController.clear();
              quantityController.clear();
              Navigator.pop(context);
            },
            child: Text('Update')
          )
        ],
      ),
    );
  }

  // Toggle completion status
  Future<void> toggleCheck(int id, bool isChecked) async {
    print('$id, $isChecked');
    await supabase.from('products').update({'checked': !isChecked}).eq('id', id);
  }

  // Delete a todo
  Future<void> deleteProduct(int id) async {
    await supabase.from('products').delete().eq('id', id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
            top: 32,
            bottom: 88,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '🛒 Shopping List',
                style: TextStyle(
                  fontSize: 32
                ),
              ),
              const SizedBox(height: 32),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          // LEFT
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(
                                  'Quantity: ${product['quantity']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.grey.shade600
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // RIGHT
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [

                                // Check
                                Checkbox(
                                  value: product['checked'],
                                  onChanged: (value) => toggleCheck(product['id'], product['checked'])
                                ),

                                // Edit
                                product['checked'] == false
                                ? IconButton(
                                    onPressed: () => editProductDialog(index),
                                    icon: Icon(Icons.edit)
                                  )
                                : const SizedBox(),

                                // Delete
                                IconButton(
                                  onPressed: () => deleteProduct(product['id']),
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red
                                  )
                                ),

                              ],
                            )
                          )

                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addProductDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}