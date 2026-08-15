import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/contact.dart';
import 'package:dis_app/modules/contacts/contact_detail_screen.dart';
import 'package:dis_app/modules/contacts/widgets/contact_card.dart';
import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:dis_app/widgets/animated_empty_state.dart';
import 'package:dis_app/widgets/animated_list_view.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Kontakte-Screen - Zeigt alle Kontakte mit Filtern an
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _dataEntry = getIt<DataEntry>();

  ContactCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      // Kein eigener Titel und kein zweiter Rückweg: Beides steht in der
      // Kopfzeile der Arbeitsfläche darüber. Übrig bleibt die Filterreihe.
      appBar: StandardAppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Column(
            children: [
              // Kategorie-Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(l10n.contactsFilterAll),
                      selected: _selectedCategory == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    for (final category in ContactCategory.values)
                      if (category != ContactCategory.emergency)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category.label),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? category : null;
                              });
                            },
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: _dataEntry.contactsBox.listenable(),
        builder: (context, box, _) {
          var contacts = _dataEntry.getContacts().toList();

          // Filter nach Kategorie
          if (_selectedCategory != null) {
            contacts = contacts
                .where((c) => c.category == _selectedCategory)
                .toList();
          }

          // Sortieren nach Name
          contacts.sort((a, b) => a.name.compareTo(b.name));

          if (contacts.isEmpty) {
            return AnimatedEmptyState(
              icon: _selectedCategory != null
                  ? Icons.search_off
                  : Icons.contacts_outlined,
              title: _selectedCategory != null
                  ? l10n.contactsEmptyFilteredTitle
                  : l10n.contactsEmptyTitle,
              subtitle: _selectedCategory != null
                  ? l10n.contactsEmptyFilteredSubtitle
                  : l10n.contactsEmptySubtitle,
            );
          }

          return AnimatedListView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              context.safeBottomPaddingForFab,
            ),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ContactCard(
                contact: contact,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          ContactDetailScreen(contactId: contact.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      // FloatingActionButton wird jetzt zentral im MainScreen verwaltet
    );
  }
}
