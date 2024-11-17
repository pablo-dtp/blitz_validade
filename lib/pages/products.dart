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

  // Função para formatar a data no formato dd-MM-yy
  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date); // Converte para DateTime
      DateFormat dateFormat = DateFormat('dd/MM/yyyy'); // Define o formato com dois últimos dígitos do ano
      return dateFormat.format(parsedDate); // Retorna a data formatada
    } catch (e) {
      print('Erro ao formatar a data: $e');
      return date; // Retorna a data original se houver erro
    }
  }

  // Função para buscar as validades da API
  Future<void> _fetchValidades() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');  // Recuperando o token armazenado

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token não encontrado. Faça login novamente.')) 
      );
      return;
    }

    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/get_validades');  // URL da API

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',  // Adicionando o token no cabeçalho
        },
      );  

      if (response.statusCode == 200) {
        setState(() {
          validades = json.decode(response.body)['validades'];
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao buscar as validades. Tente novamente.'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer requisição: $e'))
      );
    }
  }

  // Função para ordenar a lista por validade ou quantidade
  void _sortValidades(String key) {
    setState(() {
      selectedFilter = key;
      sortAscending = !sortAscending; // Alterna a direção da ordenação
      if (key == 'data_validade') {
        validades.sort((a, b) {
          try {
            DateTime dateA = DateTime.parse(a['data_validade']);
            DateTime dateB = DateTime.parse(b['data_validade']);
            return sortAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
          } catch (e) {
            print("Erro ao parsear data: ${a['data_validade']} e ${b['data_validade']}. Erro: $e");
            return 0; // Caso falhe, não altera a ordenação
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
    _fetchValidades();  // Chama a função para buscar as validades inicialmente
  }

  @override
  Widget build(BuildContext context) {
    // Calculando larguras proporcionais
    double width = MediaQuery.of(context).size.width;
    double productWidth = width * 0.3; // 40% para o código e descrição
    double validityWidth = width * 0.2; // 30% para validade
    double quantityWidth = width * 0.3; // 30% para quantidade

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Center(
          child: Image.asset('assets/logo.png', width: 80, height: 80),
        ),
      ),
      body: Container(
        color: AppColors.primaryColor, // Fundo vermelho para o corpo
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
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical, // Rolagem apenas para baixo
                      child: Column(
                        children: [
                          // Cabeçalhos para ordenar
                          Row(
                            children: [
                              // Coluna PRODUTO (sem filtro)
                              Container(
                                width: productWidth,
                                child: Center(
                                  child: const Text(
                                    'Produto',
                                    style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Coluna VALIDADE com setas de filtro
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
                                        // Mostrar a seta apenas se for o filtro ativo
                                        if (selectedFilter == 'data_validade') 
                                          Icon(
                                            sortAscending
                                                ? Icons.arrow_upward 
                                                : Icons.arrow_downward,
                                            size: 16,
                                            color: Colors.black,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              // Coluna QUANTIDADE com setas de filtro
                              Container(
                                width: quantityWidth,
                                child: GestureDetector(
                                  onTap: () => _sortValidades('quantidade'),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center, // Centraliza a quantidade
                                      children: [
                                        const Text(
                                          'Quantidade',
                                          style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                        // Mostrar a seta apenas se for o filtro ativo
                                        if (selectedFilter == 'quantidade') 
                                          Icon(
                                            sortAscending
                                                ? Icons.arrow_upward 
                                                : Icons.arrow_downward,
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
                          const Divider(), // Linha divisória após os cabeçalhos

                          // Lista de validades dentro do container
                          Column(
                            children: validades.map((validade) {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,  // Centraliza os itens horizontalmente
                                    children: [
                                      // Unificando Produto e Descrição com 2 linhas
                                      Container(
                                        width: productWidth,  // 40% da largura da tela
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,  // Alinhamento à esquerda
                                          children: [
                                            // Código do Produto (Produto)
                                            RichText(
                                              text: TextSpan(
                                                style: const TextStyle(fontSize: 12, color: Colors.black), // Estilo padrão
                                                children: [
                                                  TextSpan(
                                                    text: "CÓDIGO: ", 
                                                    style: const TextStyle(fontWeight: FontWeight.bold), // "CÓDIGO:" em negrito
                                                  ),
                                                  TextSpan(
                                                    text: "${validade['produto']}", 
                                                    style: const TextStyle(fontWeight: FontWeight.normal), // Normal para o valor
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Descrição do Produto
                                            RichText(
                                              text: TextSpan(
                                                style: const TextStyle(fontSize: 12, color: Colors.black), // Estilo padrão
                                                children: [
                                                  TextSpan(
                                                    text: "DESCRIÇÃO: ", 
                                                    style: const TextStyle(fontWeight: FontWeight.bold), // "DESCRIÇÃO:" em negrito
                                                  ),
                                                  TextSpan(
                                                    text: "${validade['descricao']}", 
                                                    style: const TextStyle(fontWeight: FontWeight.normal), // Normal para o valor
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Validade
                                      Container(
                                        width: validityWidth, // 30% da largura
                                        child: Center(
                                          child: Text(
                                            formatDate(validade['data_validade']),
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      // Quantidade centralizada
                                      Container(
                                        width: quantityWidth, // 30% da largura
                                        child: Center(
                                          child: Text(
                                            validade['quantidade'].toString(),
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(), // Linha divisória após cada item
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
