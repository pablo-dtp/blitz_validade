import 'imports.dart';
import 'package:http/http.dart' as http;

class UserTable extends StatefulWidget {
  const UserTable({super.key});

  @override
  _UserTableState createState() => _UserTableState();

  void refreshTable(BuildContext context) {
    _UserTableState? state = context.findAncestorStateOfType<_UserTableState>();
    if (state != null) {
      state._fetchUsers();
    }
  }
}

class _UserTableState extends State<UserTable> {
  List<Map<String, dynamic>> users = [];
  bool isNameAscending = true;
  bool isPermissionAscending = true;
  String? selectedFilter = "name";

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('${dotenv.env['API_BASE_URL']}/get_users'));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        setState(() {
          users = List<Map<String, dynamic>>.from(responseBody['users']);
          if (selectedFilter == "name") {
            users.sort((a, b) => isNameAscending
                ? a['name'].compareTo(b['name'])
                : b['name'].compareTo(a['name']));
          } else if (selectedFilter == "permission_level") {
            users.sort((a, b) => isPermissionAscending
                ? a['permission_level'].compareTo(b['permission_level'])
                : b['permission_level'].compareTo(a['permission_level']));
          }
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
    List<String> prepositions = ['da', 'de', 'do', 'das', 'dos', 'e'];
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

  Future<void> _updateUser(int userId, String name, int permissionLevel) async {
    try {
      final response = await http.put(
        Uri.parse('${dotenv.env['API_BASE_URL']}/update_user/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'permission_level': permissionLevel,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário atualizado com sucesso!')),
        );
        _fetchUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar o usuário')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer requisição: $e')),
      );
    }
  }

  Future<void> _deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${dotenv.env['API_BASE_URL']}/delete_user/$userId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário deletado com sucesso!')),
        );
        _fetchUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deletar o usuário')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer requisição: $e')),
      );
    }
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
      child: SizedBox(
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
                                              _showEditDialog(user);
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(Icons.delete, color: Colors.black),
                                            title: Text(
                                              'Deletar Usuário',
                                              style: TextStyle(color: Colors.black),
                                            ),
                                            onTap: () {
                                              _deleteUser(user['id']);
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

  void _showEditDialog(Map<String, dynamic> user) {
    TextEditingController nameController = TextEditingController(text: user['name']);
    int permissionLevel = user['permission_level'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Usuário'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              DropdownButton<int>(
                value: permissionLevel,
                onChanged: (int? newValue) {
                  setState(() {
                    permissionLevel = newValue!;
                  });
                },
                items: [
                  DropdownMenuItem(value: 1, child: Text('Repositor')),
                  DropdownMenuItem(value: 2, child: Text('Gerente')),
                  DropdownMenuItem(value: 3, child: Text('Admin')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _updateUser(user['id'], nameController.text, permissionLevel);
                Navigator.pop(context);
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}
