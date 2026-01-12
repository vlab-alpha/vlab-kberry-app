import 'package:flutter/material.dart';

class PositionMenu extends StatelessWidget {
  final Map<String, List<String>> positionsPaths;
  final String? selectedPositionPath;
  final ValueChanged<String> onPositionSelected;
  final bool expandOnStart;

  // Map von bekannten Räumen zu Icons
  static const Map<String, IconData> roomIcons = {
    "Wohnzimmer": Icons.tv,
    "Haus": Icons.home,
    "Garten": Icons.grass,
    "EG": Icons.looks_one_rounded,
    "OG": Icons.looks_two_rounded,
    "Schlafzimmer": Icons.bed,
    "Küche": Icons.kitchen,
    "Bad": Icons.bathtub,
    "Gäste WC": Icons.wc,
    "Umkleideraum": Icons.checkroom_outlined,
    "Eingang": Icons.door_back_door_outlined,
    "Gang": Icons.calendar_view_day_sharp,
    "Büro": Icons.work,
    "Flur": Icons.flood,
    "Esszimmer": Icons.restaurant,
    "Blau Kinderzimmer": Icons.child_care,
    "Gelb Kinderzimmer": Icons.child_care,
    // hier können weitere Räume hinzugefügt werden
  };

  const PositionMenu({
    super.key,
    required this.positionsPaths,
    required this.selectedPositionPath,
    required this.onPositionSelected,
    this.expandOnStart = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      width: 280,
      color: Color(0xFFDADADA),
      child: ListView(
        padding: EdgeInsets.zero, // kein Rand außen
        children: positionsPaths.entries.map((entry) {
          final category = entry.key;
          final items = entry.value;

          final controller = ExpansionTileController();

          // Wenn expandOnStart = true, nach dem ersten Frame expandieren:
          if (expandOnStart) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.expand();
            });
          }

          return Card(
            // <-- kein Außenabstand
            elevation: 1,

            // optional: kein Schatten
            color: Color(0xFF3A3A3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // keine Rundung nötig
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 5),
              // enger
              childrenPadding: EdgeInsets.zero,
              // Kinder auch bündig
              backgroundColor: Colors.grey.shade200,
              collapsedBackgroundColor: Colors.grey.shade200,
              leading: Icon(
                Icons.layers_rounded,
                color: Colors.blueGrey.shade700,
              ),
              title: Text(
                category,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.blueGrey.shade800,
                ),
              ),
              children: items.map((item) {
                final isSelected = item == selectedPositionPath;
                final iconData = roomIcons[item] ?? Icons.question_mark;

                return ListTile(
                  dense: true,
                  tileColor: isSelected
                      ? Colors.blueGrey.shade100
                      : Colors.black,
                  leading: Icon(
                    iconData,
                    color: isSelected
                        ? Colors.blueGrey.shade900
                        : Colors.grey.shade700,
                  ),
                  title: Text(
                    item,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.blueGrey.shade900
                          : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  onTap: () => onPositionSelected(item),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.blueGrey.shade700,
                        )
                      : null,
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
