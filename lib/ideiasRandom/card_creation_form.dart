import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_icons.dart' as iconsGlobals;

class CardCreationForm extends StatefulWidget {
  const CardCreationForm({super.key});

  @override
  State<CardCreationForm> createState() => _CardCreationFormState();
}


class _CardCreationFormState extends State<CardCreationForm> {
  int? selectedIndex;

  final TextEditingController controllerTituloDoCard =
  TextEditingController();


  @override
  void dispose() {
    controllerTituloDoCard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Card")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
            child: TextField(
              controller: controllerTituloDoCard,
              decoration: const InputDecoration(
                labelText: "Nome do Card",
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Escolha um ícone',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 100,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: iconsGlobals.AppIcons.iconsDisponiveis.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue[100]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        iconsGlobals.AppIcons.iconsDisponiveis[index],
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: salvarNoBd,
          child: const Text("Salvar"),
        ),
      ),
    );
  }

  Future<void> salvarNoBd() async {
    final titulo = controllerTituloDoCard.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    // alidações mínimas
    if (user == null) return;

    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite um título")),
      );
      return;
    }

    if (selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione um ícone")),
      );
      return;
    }

    // Cria documento com ID automático
    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('memorizacoes')
        .doc(); // ID automático

    await docRef.set({
      'titulo': titulo,
      'icon': iconsGlobals.AppIcons.iconsDisponiveis[selectedIndex!],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // opcional: voltar tela
    Navigator.pop(context);
  }
}