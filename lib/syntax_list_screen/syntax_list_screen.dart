import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../login_screen/login_screen.dart';
import '../syntax_form_screen/syntax_form_screen.dart';
import '../syntax_viewer_screen/syntax_viewer_screen.dart';

class SyntaxListScreen extends StatefulWidget {
  final String tituloDoCard; // isso aqui é o cardId
  final String nomeDoCard; // nome exibido do card, usado no título da tela

  const SyntaxListScreen({
    super.key,
    required this.tituloDoCard,
    required this.nomeDoCard,
  });

  @override
  State<SyntaxListScreen> createState() => _SyntaxListScreenState();
}

class _SyntaxListScreenState extends State<SyntaxListScreen> {
  bool _isNavigating = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _goToAddSintaxe() async {
    if (_isNavigating) return;

    _isNavigating = true;

    // força a navegação fora do frame atual
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await Navigator.push(
        context,
        _createRoute(
          SyntaxFormScreen(
                cardId: widget.tituloDoCard,
              ),
        ),
      );

      _isNavigating = false;
    });
  }

  Future<void> _goToEditSintaxe(
      String subcardId, String titulo, String sintaxe) async {
    if (_isNavigating) return;

    _isNavigating = true;

    // força a navegação fora do frame atual
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await Navigator.push(
        context,
        _createRoute(
          SyntaxFormScreen(
            cardId: widget.tituloDoCard,
            subcardId: subcardId,
            initialTitulo: titulo,
            initialSintaxe: sintaxe,
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
        title: Text(widget.nomeDoCard),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Pesquisar sintaxe ...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

          final allDocs = snapshot.data?.docs ?? [];

          if (allDocs.isEmpty) {
            return const Center(child: Text('Nenhuma sintaxe cadastrada.'));
          }

          final docs = _searchQuery.isEmpty
              ? allDocs
              : allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final titulo = (data['titulo'] ?? '').toString().toLowerCase();
                  final sintaxe = (data['sintaxe'] ?? '').toString().toLowerCase();
                  return titulo.contains(_searchQuery) ||
                      sintaxe.contains(_searchQuery);
                }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text('Nenhuma sintaxe encontrada.'));
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
                              _createRoute( SyntaxViewerScreen(
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
                              _goToEditSintaxe(subcardId, titulo, sintaxe);
                            }
                          },
                          itemBuilder: (context) =>
                          const [
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
          ),
        ],
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

