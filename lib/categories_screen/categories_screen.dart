import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../syntax_list_screen/syntax_list_screen.dart';
import 'category_form_screen.dart';
import '../app_icons.dart' as iconsGlobals;

class IconFormResult {
  final int selectedIndex;
  final String text;

  IconFormResult({
    required this.selectedIndex,
    required this.text,
  });
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {

  int? selectedIndex;


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("CodeBit"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _confirmarLogout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user?.uid)
            .collection('memorizacoes')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar dados'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text('Nenhum card cadastrado ainda.'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String titulo = data['titulo'] ?? 'Sem título';
              final String iconPath = data['icon'] ?? '';
              final String cardId = doc.id;

              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                child: ListTile(
                  leading: iconPath.isNotEmpty
                      ? SvgPicture.asset(
                    iconPath,
                    width: 30,
                    height: 30,
                  )
                      : const Icon(Icons.folder),

                  title: Text(titulo),

                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "excluir") {
                        excluirDoBd(cardId);
                      } else if (value == "editar") {
                        _abrirFormularioDeEdicao(context, cardId);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: "excluir",
                        child: Icon(Icons.delete_outline, color: Colors.red),
                      ),
                      PopupMenuItem(
                        value: "editar",
                        child: Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SyntaxListScreen(
                          tituloDoCard: cardId,
                          nomeDoCard: titulo,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CategoryFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  void excluirDoBd(String cardId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(user.uid)
          .collection("memorizacoes")
          .doc(cardId)
          .delete();
    }
  }

  void editar(String cardId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null){
      //await FirebaseFirestore.instance
    }
  }



  Future<void> _confirmarLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // obriga escolher uma opção
      builder: (context) {
        return AlertDialog(
          title: const Text("Sair"),
          content: const Text("Deseja realmente sair da conta?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Sair"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
    }
  }



  void _abrirFormularioDeEdicao(BuildContext context, String cardId) {
    final TextEditingController controller = TextEditingController();

     showDialog<IconFormResult>(
      context: context,
      builder: (context) {
        int selectedIndex = -1;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: SizedBox(
                width: 350,
                height: 550,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Text("Editar nome e icon do card", style: TextStyle(fontSize: 22),),

                      const SizedBox(height: 10),

                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: "Novo nome ...",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 80,
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
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancelar"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (selectedIndex == -1 ||
                                  controller.text.isEmpty) {
                                return;
                              }

                              Navigator.pop(
                                context,
                                IconFormResult(
                                  selectedIndex: selectedIndex,
                                  text: controller.text,

                                ),
                              );
                              salvarEdicao(selectedIndex, controller.text, cardId);
                            },
                            child: const Text("Salvar"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

  }
}

Future <void> salvarEdicao(int selectedIndex, String text, String cardId) async {

  await FirebaseFirestore.instance
      .collection("usuarios")
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection("memorizacoes")
      .doc(cardId)
      .update({
    "icon": iconsGlobals.AppIcons.iconsDisponiveis[selectedIndex],
    "titulo": text
  });

}







