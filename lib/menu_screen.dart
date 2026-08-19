import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<_MenuListItem> menus = [
    _MenuListItem(
      description: 'Simple demonstration of unity flutter library',
      route: '/house',
      title: 'Simple Unity Demo',
    ),
    _MenuListItem(
      description: 'Simple demonstration of ar foundation',
      route: '/oar',
      title: 'AR with flutter',
    ),
    _MenuListItem(
      description: 'json to 3d',
      route: '/json',
      title: 'JSON TO 3D',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter With Unity'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: menus.length,
          itemBuilder: (BuildContext context, int i) {
            return ListTile(
              title: Text(menus[i].title),
              subtitle: Text(menus[i].description),
              onTap: () {
                Navigator.of(context).pushNamed(
                  menus[i].route,
                );
                // Navigator.of(context).pushNamed("/house");
              },
            );
          },
        ),
      ),
    );
  }
}

class _MenuListItem {
  final String title;
  final String description;
  final String route;

  _MenuListItem({
    required this.title,
    required this.description,
    required this.route,
  });
}
