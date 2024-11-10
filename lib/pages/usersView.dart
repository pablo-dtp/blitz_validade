import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserTable extends StatefulWidget {
  const UserTable({super.key});

  @override
  _UserTableState createState() => _UserTableState();

  // Método público para atualizar os dados da tabela
  void refreshTable() {
    _UserTableState? state = this.createState();
    state._fetchUsers(); // Chama a função de atualizar dados
  }
}

class _UserTableState extends State<UserTable> {
  List<Map<String, dynamic>> users = [];
  bool isNameAscending = true;
  bool isPermissionAscending = true;
  String? selectedFilter = "name"; // Começa como filtro por nome (A-Z).

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/get_users'));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        setState(() {
          users = List<Map<String, dynamic>>.from(responseBody['users']);
          users.sort((a, b) => a['name'].compareTo(b['name']));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar usuários')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer requisição: $e')),
      );
    }
  }

  String getPermissionLevelText(int level) {
    switch (level) {
      case 1:
        return 'Repositor';
      case 2:
        return 'Gerente';
      case 3:
        return 'Admin';
      default:
        return 'Desconhecido';
    }
  }

  String limitNameToTwoWords(String fullName) {
    List<String> prepositions = ['da', 'de', 'do', 'das', 'dos', 'e']; // Lista de preposições comuns
    List<String> nameParts = fullName.split(' ');

    String firstName = '';
    String secondName = '';

    for (var name in nameParts) {
      if (firstName.isEmpty && !prepositions.contains(name.toLowerCase())) {
        firstName = name;
      } else if (secondName.isEmpty && !prepositions.contains(name.toLowerCase())) {
        secondName = name;
      }

      if (firstName.isNotEmpty && secondName.isNotEmpty) {
        break;
      }
    }

    return '$firstName $secondName'.trim();
  }

  void _toggleSortOrder(String filter) {
    setState(() {
      if (filter == "name") {
        isNameAscending = !isNameAscending;
        selectedFilter = "name";
        users.sort((a, b) => isNameAscending
            ? a['name'].compareTo(b['name'])
            : b['name'].compareTo(a['name']));
      } else if (filter == "permission_level") {
        isPermissionAscending = !isPermissionAscending;
        selectedFilter = "permission_level";
        users.sort((a, b) => isPermissionAscending
            ? a['permission_level'].compareTo(b['permission_level'])
            : b['permission_level'].compareTo(a['permission_level']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildUserTable();
  }

  Widget _buildUserTable() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        // Limita a altura da tabela a 60% da altura da tela
        height: MediaQuery.of(context).size.height * 0.6,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 30,
              columns: [
                DataColumn(
                  label: GestureDetector(
                    onTap: () {
                      _toggleSortOrder("name");
                    },
                    child: Row(
                      children: [
                        Text(
                          'Nome Completo',
                          style: const TextStyle(color: Colors.black),
                        ),
                        if (selectedFilter == "name") ...[
                          Icon(
                            isNameAscending ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 16,
                            color: Colors.black,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                DataColumn(
                  label: GestureDetector(
                    onTap: () {
                      _toggleSortOrder("permission_level");
                    },
                    child: Row(
                      children: [
                        Text(
                          'Função',
                          style: const TextStyle(color: Colors.black),
                        ),
                        if (selectedFilter == "permission_level") ...[
                          Icon(
                            isPermissionAscending ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 16,
                            color: Colors.black,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                DataColumn(
                  label: Container(
                    alignment: Alignment.centerRight,
                    child: Text(''),
                  ),
                ),
              ],
              rows: users
                  .map((user) => DataRow(cells: [
                        DataCell(
                          Text(
                            limitNameToTwoWords(user['name']),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        DataCell(
                          Text(
                            getPermissionLevelText(user['permission_level']),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        DataCell(
                          Container(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.more_vert, color: Colors.black),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: Icon(Icons.edit, color: Colors.black),
                                            title: Text(
                                              'Editar Usuário',
                                              style: TextStyle(color: Colors.black),
                                            ),
                                            onTap: () {
                                              // Ação de editar usuário
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(Icons.delete, color: Colors.black),
                                            title: Text(
                                              'Deletar Usuário',
                                              style: TextStyle(color: Colors.black),
                                            ),
                                            onTap: () {
                                              // Ação de deletar usuário
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ]))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
