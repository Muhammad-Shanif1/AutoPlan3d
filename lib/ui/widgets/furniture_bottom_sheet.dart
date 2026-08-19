import 'package:flutter/material.dart';

class FurnitureItem {
  final String name;
  final String image;
  final IconData icon;
  final String prefabName;
  const FurnitureItem({
    required this.name,
    required this.image,
    required this.icon,
    required this.prefabName,
  });
}

class FurnitureCategory {
  final String label;
  final String emoji;
  final List<String> prefabNames;
  const FurnitureCategory({
    required this.label,
    required this.emoji,
    required this.prefabNames,
  });
}

final List<FurnitureItem> kFurnitureItems = [
  FurnitureItem(name: 'Sofa 1', image: '', icon: Icons.weekend, prefabName: 'sofa_1'),
  FurnitureItem(name: 'Almari', image: '', icon: Icons.kitchen, prefabName: 'almari'),
  FurnitureItem(name: 'Chair 1', image: '', icon: Icons.chair, prefabName: 'chair_1'),
  FurnitureItem(name: 'Closet 1', image: '', icon: Icons.kitchen, prefabName: 'closet_1'),
  FurnitureItem(name: 'Single Sofa 1', image: '', icon: Icons.weekend, prefabName: 'single_sofa_1'),
  FurnitureItem(name: 'Wall', image: '', icon: Icons.crop_square, prefabName: 'Wall'),
  FurnitureItem(name: 'Sofa 2', image: '', icon: Icons.weekend, prefabName: 'sofa_2'),
  FurnitureItem(name: 'Camera', image: '', icon: Icons.camera_alt, prefabName: 'camera'),
  FurnitureItem(name: 'Door 1', image: '', icon: Icons.door_front_door, prefabName: 'door_1'),
  FurnitureItem(name: 'Shelf', image: '', icon: Icons.shelves, prefabName: 'shelf'),
  FurnitureItem(name: 'Alarm Clock', image: '', icon: Icons.alarm, prefabName: 'alaram_clock'),
  FurnitureItem(name: 'Car 1', image: '', icon: Icons.directions_car, prefabName: 'car_1'),
  FurnitureItem(name: 'Bench', image: '', icon: Icons.event_seat, prefabName: 'bench'),
  FurnitureItem(name: 'Speaker 1', image: '', icon: Icons.speaker, prefabName: 'speaker_1'),
  FurnitureItem(name: 'Chair 2', image: '', icon: Icons.chair, prefabName: 'chair_2'),
  FurnitureItem(name: 'Chair 3', image: '', icon: Icons.chair, prefabName: 'chair_3'),
  FurnitureItem(name: 'Chair 4', image: '', icon: Icons.chair, prefabName: 'chair_4'),
  FurnitureItem(name: 'Single Sofa 2', image: '', icon: Icons.weekend, prefabName: 'single_sofa_2'),
  FurnitureItem(name: 'Closet 2', image: '', icon: Icons.kitchen, prefabName: 'closet_2'),
  FurnitureItem(name: 'Closet 3', image: '', icon: Icons.kitchen, prefabName: 'closet_3'),
  FurnitureItem(name: 'Sofa 3', image: '', icon: Icons.weekend, prefabName: 'sofa_3'),
  FurnitureItem(name: 'Sofa 4', image: '', icon: Icons.weekend, prefabName: 'sofa_4'),
  FurnitureItem(name: 'Sofa 5', image: '', icon: Icons.weekend, prefabName: 'sofa_5'),
  FurnitureItem(name: 'Sofa Set', image: '', icon: Icons.weekend, prefabName: 'sofa_set'),
  FurnitureItem(name: 'Pillow', image: '', icon: Icons.bed, prefabName: 'pillow'),
  FurnitureItem(name: 'Desk 1', image: '', icon: Icons.desk, prefabName: 'desk_1'),
  FurnitureItem(name: 'Chair 5', image: '', icon: Icons.chair, prefabName: 'chair_5'),
  FurnitureItem(name: 'Door 2', image: '', icon: Icons.door_front_door, prefabName: 'door_2'),
  FurnitureItem(name: 'Door 3', image: '', icon: Icons.door_front_door, prefabName: 'door_3'),
  FurnitureItem(name: 'Door 4', image: '', icon: Icons.door_front_door, prefabName: 'door_4'),
  FurnitureItem(name: 'Door 5', image: '', icon: Icons.door_front_door, prefabName: 'door_5'),
  FurnitureItem(name: 'Door 6', image: '', icon: Icons.door_front_door, prefabName: 'door_6'),
  FurnitureItem(name: 'Door 7', image: '', icon: Icons.door_front_door, prefabName: 'door_7'),
  FurnitureItem(name: 'Door 8', image: '', icon: Icons.door_front_door, prefabName: 'door_8'),
  FurnitureItem(name: 'Door 9', image: '', icon: Icons.door_front_door, prefabName: 'door_9'),
  FurnitureItem(name: 'Door 10', image: '', icon: Icons.door_front_door, prefabName: 'door_10'),
  FurnitureItem(name: 'Door 11', image: '', icon: Icons.door_front_door, prefabName: 'door_11'),
  FurnitureItem(name: 'Door 12', image: '', icon: Icons.door_front_door, prefabName: 'door_12'),
  FurnitureItem(name: 'Door 13', image: '', icon: Icons.door_front_door, prefabName: 'door_13'),
  FurnitureItem(name: 'Door 14', image: '', icon: Icons.door_front_door, prefabName: 'door_14'),
  FurnitureItem(name: 'Door 15', image: '', icon: Icons.door_front_door, prefabName: 'door_15'),
  FurnitureItem(name: 'Door 16', image: '', icon: Icons.door_front_door, prefabName: 'door_16'),
  FurnitureItem(name: 'Door 17', image: '', icon: Icons.door_front_door, prefabName: 'door_17'),
  FurnitureItem(name: 'Sofa 6', image: '', icon: Icons.weekend, prefabName: 'sofa_6'),
  FurnitureItem(name: 'Dresser', image: '', icon: Icons.kitchen, prefabName: 'dresser'),
  FurnitureItem(name: 'Nightstand', image: '', icon: Icons.nightlight, prefabName: 'nightstand_1'),
  FurnitureItem(name: 'Gate 1', image: '', icon: Icons.garage, prefabName: 'gate_1'),
  FurnitureItem(name: 'Gate 2', image: '', icon: Icons.garage, prefabName: 'gate_2'),
  FurnitureItem(name: 'Glass Drawer', image: '', icon: Icons.kitchen, prefabName: 'glass_drawer'),
  FurnitureItem(name: 'Laptop', image: '', icon: Icons.laptop, prefabName: 'laptop'),
  FurnitureItem(name: 'Plant 1', image: '', icon: Icons.local_florist, prefabName: 'plant_1'),
  FurnitureItem(name: 'Table 1', image: '', icon: Icons.table_restaurant, prefabName: 'table_1'),
  FurnitureItem(name: 'Table 2', image: '', icon: Icons.table_restaurant, prefabName: 'table_2'),
  FurnitureItem(name: 'Kitchen 1', image: '', icon: Icons.kitchen, prefabName: 'kitchen_1'),
  FurnitureItem(name: 'Kitchen 2', image: '', icon: Icons.kitchen, prefabName: 'kitchen_2'),
  FurnitureItem(name: 'Street Light 1', image: '', icon: Icons.light, prefabName: 'street_light_1'),
  FurnitureItem(name: 'Plant 2', image: '', icon: Icons.local_florist, prefabName: 'plant_2'),
  FurnitureItem(name: 'Plant 3', image: '', icon: Icons.local_florist, prefabName: 'plant_3'),
  FurnitureItem(name: 'Table 3', image: '', icon: Icons.table_restaurant, prefabName: 'table_3'),
  FurnitureItem(name: 'Dining Table', image: '', icon: Icons.table_restaurant, prefabName: 'dainning_table'),
  FurnitureItem(name: 'Mirror Comode', image: '', icon: Icons.checkroom, prefabName: 'mirror_comode'),
  FurnitureItem(name: 'Mirror Comode 2', image: '', icon: Icons.checkroom, prefabName: 'mirror_comode_2'),
  FurnitureItem(name: 'Car 2', image: '', icon: Icons.directions_car, prefabName: 'car_2'),
  FurnitureItem(name: 'Table 4', image: '', icon: Icons.table_restaurant, prefabName: 'table_4'),
  FurnitureItem(name: 'Street Lamp', image: '', icon: Icons.light, prefabName: 'street_lamp'),
  FurnitureItem(name: 'Bicycle', image: '', icon: Icons.pedal_bike, prefabName: 'bike_cycle'),
  FurnitureItem(name: 'TV', image: '', icon: Icons.tv, prefabName: 'tv'),
  FurnitureItem(name: 'Speaker 2', image: '', icon: Icons.speaker, prefabName: 'speaker_2'),
  FurnitureItem(name: 'Stairs 1', image: '', icon: Icons.stairs, prefabName: 'stairs_1'),
  FurnitureItem(name: 'Stairs 2', image: '', icon: Icons.stairs, prefabName: 'stairs_2'),
  FurnitureItem(name: 'Street Light 2', image: '', icon: Icons.light, prefabName: 'streetlight_2'),
  FurnitureItem(name: 'Toilet', image: '', icon: Icons.wc, prefabName: 'toilet'),
  FurnitureItem(name: 'Car 3', image: '', icon: Icons.directions_car, prefabName: 'car_3'),
  FurnitureItem(name: 'Tree', image: '', icon: Icons.park, prefabName: 'tree'),
  FurnitureItem(name: 'Car 4', image: '', icon: Icons.directions_car, prefabName: 'car_4'),
  FurnitureItem(name: 'Gate 3', image: '', icon: Icons.garage, prefabName: 'gate_3'),
  FurnitureItem(name: 'Table 5', image: '', icon: Icons.table_restaurant, prefabName: 'table_5'),
  FurnitureItem(name: 'Computer Desktop', image: '', icon: Icons.desktop_windows, prefabName: 'computer_desktop'),
];

final List<FurnitureCategory> kFurnitureCategories = [
  FurnitureCategory(
    label: 'Sofas',
    emoji: '🛋️',
    prefabNames: [
      'sofa_1', 'sofa_2', 'sofa_3', 'sofa_4',
      'sofa_5', 'sofa_6', 'sofa_set', 'single_sofa_1', 'single_sofa_2',
    ],
  ),
  FurnitureCategory(
    label: 'Chairs',
    emoji: '🪑',
    prefabNames: [
      'chair_1', 'chair_2', 'chair_3',
      'chair_4', 'chair_5', 'bench',
    ],
  ),
  FurnitureCategory(
    label: 'Bedroom',
    emoji: '🛏️',
    prefabNames: [
      'pillow', 'dresser', 'nightstand_1',
      'mirror_comode', 'mirror_comode_2',
    ],
  ),
  FurnitureCategory(
    label: 'Tables',
    emoji: '🍽️',
    prefabNames: [
      'table_1', 'table_2', 'table_3',
      'table_4', 'table_5', 'dainning_table', 'desk_1',
    ],
  ),
  FurnitureCategory(
    label: 'Doors & Gates',
    emoji: '🚪',
    prefabNames: [
      'door_1', 'door_2', 'door_3', 'door_4', 'door_5',
      'door_6', 'door_7', 'door_8', 'door_9', 'door_10',
      'door_11', 'door_12', 'door_13', 'door_14', 'door_15',
      'door_16', 'door_17', 'gate_1', 'gate_2', 'gate_3',
    ],
  ),
  FurnitureCategory(
    label: 'Kitchen',
    emoji: '🍳',
    prefabNames: ['kitchen_1', 'kitchen_2'],
  ),
  FurnitureCategory(
    label: 'Electronics',
    emoji: '📺',
    prefabNames: [
      'tv', 'laptop', 'speaker_1', 'speaker_2',
      'alaram_clock', 'computer_desktop',
    ],
  ),
  FurnitureCategory(
    label: 'Vehicles',
    emoji: '🚗',
    prefabNames: ['car_1', 'car_2', 'car_3', 'car_4', 'bike_cycle'],
  ),
  FurnitureCategory(
    label: 'Outdoor',
    emoji: '🌳',
    prefabNames: [
      'plant_1', 'plant_2', 'plant_3',
      'tree', 'street_light_1', 'streetlight_2', 'street_lamp',
    ],
  ),
  FurnitureCategory(
    label: 'Architecture',
    emoji: '🏠',
    prefabNames: [
      'Wall', 'stairs_1', 'stairs_2', 'almari',
      'closet_1', 'closet_2', 'closet_3', 'shelf', 'glass_drawer',
    ],
  ),
  FurnitureCategory(
    label: 'Bathroom',
    emoji: '🚽',
    prefabNames: ['toilet'],
  ),
  FurnitureCategory(
    label: 'Others',
    emoji: '📦',
    prefabNames: ['camera'],
  ),
];

class FurnitureBottomSheet extends StatefulWidget {
  final List<FurnitureItem> furnitureItems;
  final void Function(FurnitureItem item) onItemSelected;

  const FurnitureBottomSheet({
    super.key,
    required this.furnitureItems,
    required this.onItemSelected,
  });

  @override
  State<FurnitureBottomSheet> createState() => _FurnitureBottomSheetState();
}

class _FurnitureBottomSheetState extends State<FurnitureBottomSheet> {
  int _selectedCategoryIndex = 0;
  final ScrollController _categoryScrollController = ScrollController();
  final List<GlobalKey> _categoryKeys = List.generate(
    kFurnitureCategories.length,
    (_) => GlobalKey(),
  );

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  List<FurnitureItem> get _filteredItems {
    final prefabs = kFurnitureCategories[_selectedCategoryIndex].prefabNames;
    return widget.furnitureItems
        .where((item) => prefabs.contains(item.prefabName))
        .toList();
  }

  void _selectCategory(int index) {
    setState(() => _selectedCategoryIndex = index);
    final key = _categoryKeys[index];
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: 0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.72,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context),
          _buildCategoryChips(),
          _buildDivider(),
          Expanded(child: _buildGrid()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.widgets_rounded,
                color: Color(0xFF9D96FF), size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add to Scene',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Tap an item to place it',
                style: TextStyle(
                  color: Color(0xFF8A8AA0),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close_rounded,
                  color: Color(0xFF8A8AA0), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: kFurnitureCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = kFurnitureCategories[index];
          final isSelected = _selectedCategoryIndex == index;
          return KeyedSubtree(
            key: _categoryKeys[index],
            child: GestureDetector(
              onTap: () => _selectCategory(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6C63FF)
                      : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      cat.label,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF8A8AA0),
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      height: 0.5,
      color: Colors.white.withOpacity(0.08),
    );
  }

  Widget _buildGrid() {
    final items = _filteredItems;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined,
                color: Colors.white.withOpacity(0.2), size: 48),
            const SizedBox(height: 12),
            Text(
              'No items in this category',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => FurnitureCard(
        item: items[index],
        onTap: () {
          Navigator.pop(context);
          widget.onItemSelected(items[index]);
        },
      ),
    );
  }

  Widget _buildFooter() {
    final cat = kFurnitureCategories[_selectedCategoryIndex];
    final count = _filteredItems.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.07), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Text(
            cat.emoji,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(width: 8),
          Text(
            '${cat.label}',
            style: const TextStyle(
              color: Color(0xFF8A8AA0),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count item${count == 1 ? '' : 's'}',
              style: const TextStyle(
                color: Color(0xFF9D96FF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FurnitureCard extends StatefulWidget {
  final FurnitureItem item;
  final VoidCallback onTap;

  const FurnitureCard({super.key, required this.item, required this.onTap});

  @override
  State<FurnitureCard> createState() => _FurnitureCardState();
}

class _FurnitureCardState extends State<FurnitureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF252540),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.07),
              width: 0.8,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.item.icon,
                  color: const Color(0xFF9D96FF),
                  size: 26,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  widget.item.name,
                  style: const TextStyle(
                    color: Color(0xFFD0D0E8),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
