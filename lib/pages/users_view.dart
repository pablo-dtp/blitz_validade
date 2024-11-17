import 'package:blitz_validade/pages/users_delete.dart';
import 'package:blitz_validade/pages/users_update.dart';
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
  bool isLoading = true;
  String errorMessage = ''; // Mensagem de erro

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = ''; // Reseta a mensagem de erro
    });

    try {
      final response = await http.get(Uri.parse('${dotenv.env['API_BASE_URL']}/get_users'));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        setState(() {
          users = List<Map<String, dynamic>>.from(responseBody['users']);
          _sortUsers();
          isLoading = false;  // Dados carregados com sucesso
        });
      } else {
        setState(() {
          errorMessage = 'Erro ao carregar usuários';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao fazer requisição: $e';
        isLoading = false;
      });
    }
  }

  void _sortUsers() {
    if (selectedFilter == "name") {
      users.sort((a, b) => isNameAscending
          ? a['name'].compareTo(b['name'])
          : b['name'].compareTo(a['name']));
    } else if (selectedFilter == "permission_level") {
      users.sort((a, b) => isPermissionAscending
          ? a['permission_level'].compareTo(b['permission_level'])
          : b['permission_level'].compareTo(a['permission_level']));
    }
  }

  void _toggleSortOrder(String filter) {
    setState(() {
      if (filter == "name") {
        isNameAscending = !isNameAscending;
      } else if (filter == "permission_level") {
        isPermissionAscending = !isPermissionAscending;
      }
      selectedFilter = filter;
      _sortUsers();
    });
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

  @override
  Widget build(BuildContext context) {
    return _buildUserTable();
  }

  Widget _buildUserTable() {
    double screenWidth = MediaQuery.of(context).size.width;
    double tableWidth = screenWidth * 0.9; // 90% da largura da tela
    double marginSide = screenWidth * 0.05; // 5% de distância de cada lado

    return Container(
      margin: EdgeInsets.symmetric(horizontal: marginSide), // 5% de distância de cada lado
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
        width: tableWidth,
        height: MediaQuery.of(context).size.height * 0.6,
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Exibe indicador de carregamento
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 20,
                      columns: [
                        DataColumn(
                          label: GestureDetector(
                            onTap: () {
                              _toggleSortOrder("name");
                            },
                            child: Row(
                              children: [
                                const Text('Nome Completo', style: TextStyle(color: Colors.black)),
                                if (selectedFilter == "name") ...[ 
                                  Icon(
                                    isNameAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                    size: 10,
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
                                const Text('Função', style: TextStyle(color: Colors.black)),
                                if (selectedFilter == "permission_level") ...[ 
                                  Icon(
                                    isPermissionAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                    size: 10,
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
                            child: const Text(''), // Coluna sem texto
                          ),
                        ),
                      ],
                      rows: users.map((user) {
                        return DataRow(
                          cells: [
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
                                child: PopupMenuButton<String>(
                                  iconSize: 18,  // Tamanho do ícone reduzido
                                  onSelected: (value) {
                                    if (value == 'Editar') {
                                      showDialog(
                                        context: context,
                                        builder: (_) => UpdateUser(
                                          currentUsername: user['username'],
                                          currentName: user['name'],
                                          currentPermissionLevel: user['permission_level'],
                                          refreshUsers: () => _fetchUsers(),
                                        ),
                                      );
                                    } else if (value == 'Deletar') {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Confirmar exclusão'),
                                          content: const Text('Você tem certeza que deseja deletar este usuário?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                DeleteUser(
                                                  username: user['username'],  // Usando username agora
                                                  refreshUsers: () => _fetchUsers(),
                                                ).deleteUser(context);
                                              },
                                              child: const Text('Deletar'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'Editar',
                                      child: Text('Editar'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Deletar',
                                      child: Text('Deletar'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
      ),
    );
  }
}
