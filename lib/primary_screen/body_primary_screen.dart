import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../login_screen/login_screen.dart';
import '../second_screen/body_second_screen.dart';
import '../third_screen/sintaxis_body_view.dart';

class BodyPrimaryScreen extends StatefulWidget {
  final String tituloDoCard; // isso aqui é o cardId

  const BodyPrimaryScreen({super.key, required this.tituloDoCard});

  @override
  State<BodyPrimaryScreen> createState() => _BodyPrimaryScreenState();
}

class _BodyPrimaryScreenState extends State<BodyPrimaryScreen> {
  bool _isNavigating = false;

  Future<void> _goToAddSintaxe() async {
    if (_isNavigating) return;

    _isNavigating = true;

    // força a navegação fora do frame atual
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await Navigator.push(
        context,
        _createRoute(
          BodySecondScreen(
                cardId: widget.tituloDoCard,
              ),
        ),
      );

      _isNavigating = false;
    });
  }

  Future<void> _logout() async {
    if (_isNavigating) return;

    _isNavigating = true;

    await Future.delayed(const Duration(milliseconds: 100));

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
        _createRoute(
           Login()),
          (route) => false,
    );
  }
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Usuário não autenticado")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sintaxes Memorizer\n     Subcards"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('memorizacoes')
            .doc(widget.tituloDoCard)
            .collection('subcards')
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
            return const Center(child: Text('Nenhuma sintaxe cadastrada.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final String subcardId = doc.id;
              final titulo = data['titulo'] ?? 'Sem título';
              final sintaxe = data['sintaxe'] ?? '';

              return Hero(
                  tag: subcardId,
                  child: Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6
                ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      child:
                      ListTile(
                        onTap: () async {
                          if (_isNavigating) return;
                          _isNavigating = true;

                          // força a navegação fora do frame atual
                          WidgetsBinding.instance.addPostFrameCallback((_) async {
                            if (!mounted) return;
                            await Navigator.push(
                              context,
                              _createRoute( BodyThirdScreen(
                                  titulo: titulo, cardId: widget.tituloDoCard,
                                ),
                              ),
                            );
                            _isNavigating = false;
                          });
                        },
                        title: Text(titulo),
                        subtitle: Text(
                          sintaxe,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == "excluir") {
                              _excluirSubcard(subcardId);
                            } else if (value == "editar") {
                              _abrirFormularioDeEdicao(context,subcardId);
                            }
                          },
                          itemBuilder: (context) =>
                          const [
                            PopupMenuItem(
                              value: "excluir",
                              child: Text("Excluir"),
                            ),
                            PopupMenuItem(
                              value: "editar",
                              child: Text("Editar"),
                            ),
                          ],
                        ),
                      ),
                    )

                  ).animate()
                  .fadeIn(
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  )
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    )
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 6,
        onPressed: _goToAddSintaxe,
        child: const Icon(Icons.add),
      ).animate()
          .scale(
        duration: 500.ms,
        curve: Curves.elasticOut,
      ),
    );
  }

  void _abrirFormularioDeEdicao(
      BuildContext context,
      String subcardId,
      ) {

    final TextEditingController controller =
    TextEditingController();

    showGeneralDialog(
      context: context,

      barrierDismissible: true,
      barrierLabel: "Dialog",

      transitionDuration:
      const Duration(milliseconds: 250),

      transitionBuilder:
          (context, animation, secondaryAnimation, child) {

        return Transform.scale(
          scale: Curves.easeOutBack.transform(
            animation.value,
          ),

          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },

      pageBuilder:
          (context, animation, secondaryAnimation) {

        return StatefulBuilder(
          builder: (context, setState) {

            return Center(
              child: Dialog(
                child: SizedBox(
                  width: 250,
                  height: 200,

                  child: Padding(
                    padding: const EdgeInsets.all(12),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,

                      children: [

                        const Text(
                          "Editar Titulo",
                          style: TextStyle(fontSize: 22),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: controller,

                          decoration:
                          const InputDecoration(
                            labelText: "Novo nome ...",

                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.end,

                          children: [

                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },

                              child:
                              const Text("Cancelar"),
                            ),

                            ElevatedButton(
                              onPressed: () {

                                Navigator.pop(context);

                                _editarTituloDoCard(
                                  subcardId,
                                  controller.text,
                                );
                              },

                              child:
                              const Text("Salvar"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _excluirSubcard(String subcardId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(user.uid)
        .collection("memorizacoes")
        .doc(widget.tituloDoCard)
        .collection("subcards")
        .doc(subcardId)
        .delete();
  }

  Future<void> _editarTituloDoCard(String subcardId, String text) async {
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(user?.uid)
        .collection("memorizacoes")
        .doc(widget.tituloDoCard)
        .collection("subcards")
        .doc(subcardId)
        .update({"titulo": text});
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {

        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

