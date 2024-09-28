import 'package:flutter/material.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restaurant Menu App',
      home: MenuApp(),
    );
  }
}

class MenuApp extends StatefulWidget {
  const MenuApp({super.key});

  @override
  State<MenuApp> createState() => _MenuAppState();
}

class _MenuAppState extends State<MenuApp> {
  int currentPageIndex = 0;

  final List<Map<String, dynamic>> cartItems = [];
  final List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    pages.addAll([
      HomePage(onAddToCart: (item) {
        setState(() {
          cartItems.add(item);
        });
      }),
      CartPage(
          cartItems: cartItems,
          onRemoveFromCart: (item) {
            setState(() {
              cartItems.remove(item);
            });
          }),
      const AccountPage(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
            if (index == 1) {
              pages[1] = CartPage(
                  cartItems: cartItems,
                  onRemoveFromCart: (item) {
                    setState(() {
                      cartItems.remove(item);
                    });
                  });
            }
          });
        },
        indicatorColor: Colors.blue,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.shopping_cart),
            icon: Icon(Icons.shopping_cart_rounded),
            label: 'Cart',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_box),
            icon: Icon(Icons.account_box_outlined),
            label: 'Accounts',
          ),
        ],
      ),
      body: pages[currentPageIndex],
    );
  }
}

class HomePage extends StatelessWidget {
  final Function(Map<String, dynamic>) onAddToCart;
  const HomePage({required this.onAddToCart, super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant Menu')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              'Get all the items by  categories',
              style: theme.textTheme.bodyMedium,
            ),
            const Text(
              'Categories',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 24.0),
            MenuItemCard(
                title: 'Desserts',
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MenuPage(
                      categoryName: 'Desserts',
                      onAddToCart: onAddToCart,
                    ),
                  ));
                }),
            MenuItemCard(
                title: 'Main Course',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MenuPage(
                        categoryName: 'Main Course',
                        onAddToCart: onAddToCart,
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const MenuItemCard({required this.title, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.fastfood),
          title: Text(title),
        ),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(Map<String, dynamic>) onRemoveFromCart;

  const CartPage(
      {required this.cartItems, required this.onRemoveFromCart, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cartItems.isEmpty
          ? const Center(child: Text('Cart is empty'))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text('Price: Rs ${item['price']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      onRemoveFromCart(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('${item['name']} removed from cart')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(34.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Profile'),
            const Text('Notifications'),
            const Text('Help'),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ));
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.blue,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  final String categoryName;
  final Function(Map<String, dynamic>) onAddToCart;

  const MenuPage(
      {required this.categoryName, required this.onAddToCart, super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy JSON data for demonstration
    const String jsonData = '''
    {
      "categories": [
        {
          "name": "Desserts",
          "items": [
            {"name": "Chocolate Cake", "price": 230},
            {"name": "Ice Cream", "price": 150},
            {"name": "Cheesecake", "price": 200}
          ]
        },
        {
          "name": "Main Course",
          "items": [
            {"name": "Grilled Chicken", "price": 500},
            {"name": "Pasta Alfredo", "price": 400},
            {"name": "Vegetable Stir Fry", "price": 300}
          ]
        }
      ]
    }''';

    // Parse JSON data
    final Map<String, dynamic> data = json.decode(jsonData);
    final List<dynamic> categories = data['categories'];

    // Find items for the selected category
    final categoryItems = categories
        .firstWhere((category) => category['name'] == categoryName)['items'];

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: ListView.builder(
        itemCount: categoryItems.length,
        itemBuilder: (context, index) {
          final item = categoryItems[index];
          return ListTile(
            title: Text(item['name']),
            subtitle: Text('Price: Rs ${item['price']}'),
            trailing: ElevatedButton(
              onPressed: () {
                onAddToCart(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item['name']} added to cart')),
                );
              },
              child: const Text('Add to Cart'),
            ),
          );
        },
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MenuApp(),
            ));
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.blue,
          ),
          child: Text('Login'),
        ),
      ),
    );
  }
}
