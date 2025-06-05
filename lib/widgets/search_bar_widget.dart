
import 'package:flutter/material.dart';
import 'package:project_tpm_prak/pages/searchPage.dart'; 
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'Search title movies...',
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
        ),
        style: const TextStyle(color: Colors.white),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Searchpage())),
      ),
    );
  }
}