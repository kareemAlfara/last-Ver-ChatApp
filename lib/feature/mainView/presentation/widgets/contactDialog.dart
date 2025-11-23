import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';

class ContactDialog extends StatelessWidget {
  const ContactDialog({
    super.key,
    required this.contacts,
  });

  final List<Contact> contacts;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('اختر جهة اتصال'),
      content: Container(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            Contact contact = contacts[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text(
                  contact.displayName.isNotEmpty
                      ? contact.displayName.substring(0, 1).toUpperCase()
                      : '?',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                contact.displayName.isNotEmpty
                    ? contact.displayName
                    : 'بدون اسم',
              ),
              subtitle: Text(
                contact.phones.isNotEmpty
                    ? contact.phones.first.number
                    : 'لا يوجد رقم',
              ),
              onTap: () {
                Navigator.pop(context, contact);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء'),
        ),
      ],
    );
  }
}