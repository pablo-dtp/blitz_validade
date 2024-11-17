import 'package:shared_preferences/shared_preferences.dart';
import 'imports.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Importando o pacote intl

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  _ManageProductsPageState createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  List<dynamic> validades = [];
  bool isLoading = true;
  bool sortAscending = true; // Controle da ordenação
  String selectedFilter = 'data_validade'; // Filtro padrão (data_validade)

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      DateFormat dateFormat = DateFormat('dd/MM/yy');
      return dateFormat.format(parsedDate);
    } catch (e) {
      print('Erro ao formatar a data: $e');
      return date;
    }
  }

  Future<void> _fetchValidades() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token não encontrado. Faça login novamente.')),
      );
      return;
    }

    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/get_validades');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          validades = json.decode(response.body)['validades'];
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao buscar as validades. Tente novamente.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer requisição: $e')),
      );
    }
  }

  void _sortValidades(String key) {
    setState(() {
      selectedFilter = key;
      sortAscending = !sortAscending;
      if (key == 'data_validade') {
        validades.sort((a, b) {
          try {
            DateTime dateA = DateTime.parse(a['data_validade']);
            DateTime dateB = DateTime.parse(b['data_validade']);
            return sortAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
          } catch (e) {
            print("Erro ao parsear data: ${a['data_validade']} e ${b['data_validade']}. Erro: $e");
            return 0;
          }
        });
      } else if (key == 'quantidade') {
        validades.sort((a, b) {
          return sortAscending
              ? a['quantidade'].compareTo(b['quantidade'])
              : b['quantidade'].compareTo(a['quantidade']);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchValidades();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double productWidth = width * 0.3;
    double validityWidth = width * 0.2;
    double quantityWidth = width * 0.3;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Center(
          child: Image.asset('assets/logo.png', width: 80, height: 80),
        ),
      ),
      body: Container(
        color: AppColors.primaryColor,
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.90,
              height: MediaQuery.of(context).size.height * 0.7,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _fetchValidades,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: productWidth,
                                  child: const Center(
                                    child: Text(
                                      'Produto',
                                      style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: validityWidth,
                                  child: GestureDetector(
                                    onTap: () => _sortValidades('data_validade'),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Validade',
                                            style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
                                          if (selectedFilter == 'data_validade')
                                            Icon(
                                              sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                              size: 16,
                                              color: Colors.black,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: quantityWidth,
                                  child: GestureDetector(
                                    onTap: () => _sortValidades('quantidade'),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Quantidade',
                                            style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
                                          if (selectedFilter == 'quantidade')
                                            Icon(
                                              sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                              size: 16,
                                              color: Colors.black,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: validades.length,
                              itemBuilder: (context, index) {
                                final validade = validades[index];
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: productWidth,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(fontSize: 12, color: Colors.black),
                                                  children: [
                                                    const TextSpan(text: "CÓDIGO: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                                    TextSpan(text: "${validade['produto']}"),
                                                  ],
                                                ),
                                              ),
                                              RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(fontSize: 12, color: Colors.black),
                                                  children: [
                                                    const TextSpan(text: "DESCRIÇÃO: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                                    TextSpan(text: "${validade['descricao']}"),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: validityWidth,
                                          child: Center(
                                            child: Text(
                                              formatDate(validade['data_validade']),
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: quantityWidth,
                                          child: Center(
                                            child: Text(
                                              validade['quantidade'].toString(),
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
