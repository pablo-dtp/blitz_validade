// ignore_for_file: file_names

import 'package:http/http.dart' as http;
import 'imports.dart';  // Certifique-se de que está importando tudo que é necessário.

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _packagingController = TextEditingController(text: '1');  // Valor padrão para embalagem
  final TextEditingController _expiryDateController = TextEditingController();

  String _productName = '';
  String _productDescription = '';
  String _productBarcode = '';
  String _expiryDate = '';
  
  bool _isProductFound = false;
  bool _isQuantityFilled = false;
  bool _isPackagingFilled = false;
  bool _isDateSelected = false;

  // Função para consultar o produto no servidor
  Future<void> _fetchProductInfo(String barcode) async {
    final url = '${dotenv.env['API_BASE_URL']}/get_product'; // Alterado para o IP correto (10.0.2.2)
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'codigo_barras': barcode, 
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _productName = data['produto'].toString();
          _productDescription = data['descricao'].toString();
          _productBarcode = data['codigo_barras'].toString();
          _isProductFound = true;
        });
      } else {
        setState(() {
          _productName = 'Produto não encontrado';
          _productDescription = '';
          _productBarcode = '';
          _isProductFound = false;
        });
      }
    } catch (e) {
      setState(() {
        _productName = 'Erro ao buscar produto';
        _productDescription = '';
        _productBarcode = '';
        _isProductFound = false;
      });
    }
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime minimumDate = now.add(Duration(days: 2)); // Data mínima (hoje + 2 dias)

    // Garantir que a data inicial seja no mínimo igual à data mínima
    final DateTime initialDate = now.isBefore(minimumDate) ? minimumDate : now;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,  // Usando a data corrigida
      firstDate: minimumDate,  // Data mínima
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _expiryDate = "${pickedDate.toLocal()}".split(' ')[0];  // Formata a data para 'yyyy-mm-dd'
        _expiryDateController.text = _expiryDate;  // Atualiza o campo de texto
        _isDateSelected = true;
      });
    }
  }

  // Função para verificar se todos os campos estão preenchidos
  void _checkFields() {
    setState(() {
      _isQuantityFilled = _quantityController.text.isNotEmpty;
      _isPackagingFilled = _packagingController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,  // Cor da AppBar
        title: Center(
          child: Image.asset(
            'assets/logo.png', // Caminho da logo
            width: 80, // Tamanho da logo
            height: 80,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [AppColors.primaryColor, AppColors.auxiliaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.1, 0.6],
          ),
        ),
        child: Center(
          child: Column(
            children: [
              // Container superior com campo de texto e ícone de código de barras
              Padding(
                padding: const EdgeInsets.only(top: 40),  // Define o espaçamento do topo
                child: Align(
                  alignment: Alignment.topCenter,  // Alinha o container ao topo
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9, // 80% da largura da tela
                    height: MediaQuery.of(context).size.height * 0.09, // 18% da altura
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13), // Bordas arredondadas
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 15),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),  // Adicionando padding para conteúdo interno
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Para alinhar o campo e ícone
                      children: [
                        // Campo de texto para digitar o código de barras manualmente
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7, // Menor largura para caber na linha
                          child: TextField(
                            controller: _barcodeController,
                            decoration: InputDecoration(
                              labelText: 'LER CÓDIGO DE BARRAS',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            keyboardType: TextInputType.number, // Permite apenas números
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Apenas números (0-9)
                          ),
                        ),
                        // Ícone de código de barras ao lado do campo de texto
                        IconButton(
                          icon: Icon(Icons.barcode_reader, size: 25, color: Colors.black), // Ícone de código de barras
                          onPressed: () {
                            final barcode = _barcodeController.text;
                            if (barcode.isNotEmpty) {
                              _fetchProductInfo(barcode);  // Chama a função para buscar o produto
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),  // Espaço entre os containers
              // Container inferior com informações do produto e campos
              Container(
                width: MediaQuery.of(context).size.width * 0.9, // 80% da largura da tela
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16), // Bordas arredondadas
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),  // Adicionando padding para conteúdo interno
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField('Produto', _productName),
                    _buildField('Descrição', _productDescription),
                    _buildField('Código de Barras', _productBarcode),
                    _buildQuantityAndPackagingField(),
                    _buildDateField(),  // Data de validade vem por último agora
                    SizedBox(height: 20),  // Espaço antes do botão
                    ElevatedButton(
                      onPressed: (_isProductFound && _isQuantityFilled && _isPackagingFilled && _isDateSelected) 
                          ? () async {
                              // Preparando os dados para o envio
                              final Map<String, dynamic> productData = {
                                'produto': int.tryParse(_productName) ?? 0,  // Converte nome_produto para int (se possível), caso contrário usa 0
                                'descricao': _productDescription,  // String (não precisa de conversão)
                                'codigo_barras': _productBarcode,  // String (não precisa de conversão)
                                'quantidade': int.tryParse(_quantityController.text) ?? 0,  // Converte quantidade para int (se possível), caso contrário usa 0
                                'embalagem': int.tryParse(_packagingController.text) ?? 1,  // Converte embalagem para int (se possível), caso contrário usa 1
                                'data_validade': _expiryDate,  // String (não precisa de conversão)
                              };

                              // Enviar os dados ao servidor
                              final response = await http.post(
                                Uri.parse('${dotenv.env['API_BASE_URL']}/add_validade'),  // URL do servidor
                                headers: {'Content-Type': 'application/json'},
                                body: json.encode(productData),
                              );

                              if (response.statusCode == 200) {
                                // Caso o registro tenha sido bem-sucedido
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Produto registrado com sucesso!')),
                                );
                                // Limpar os campos após o registro
                                setState(() {
                                  _barcodeController.clear();
                                  _quantityController.clear();
                                  _packagingController.clear();
                                  _expiryDateController.clear();
                                  _productName = '';
                                  _productDescription = '';
                                  _productBarcode = '';
                                  _expiryDate = '';
                                  _isProductFound = false;
                                  _isQuantityFilled = false;
                                  _isPackagingFilled = false;
                                  _isDateSelected = false;
                                });
                              } else {
                                // Caso o registro falhe
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Erro ao registrar produto.')),
                                );
                              }
                          } 
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: (_isProductFound && _isQuantityFilled && _isPackagingFilled && _isDateSelected) 
                            ? Colors.blue 
                            : Colors.grey,
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Text(
                        'Registrar',
                        style: TextStyle(
                          color: Colors.white, 
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: $value', style: TextStyle(fontSize: 16)),
          Divider(color: const Color.fromARGB(255, 127, 121, 121)),  // Linha divisória
        ],
      ),
    );
  }

  Widget _buildQuantityAndPackagingField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),  // Espaçamento entre os campos
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quantidades e Embalagens:', style: TextStyle(fontSize: 16)),
          Row(
            children: [
              // Quantidade
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    hintText: 'Quantidade',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Somente números
                  onChanged: (text) => _checkFields(),  // Verifica se a quantidade foi preenchida
                ),
              ),
              SizedBox(width: 10),
              // Embalagem
              Expanded(
                child: TextField(
                  controller: _packagingController,
                  decoration: InputDecoration(
                    hintText: 'Embalagem',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Somente números
                  onChanged: (text) => _checkFields(),  // Verifica se a embalagem foi preenchida
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),  // Espaçamento entre os campos
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Data de Validade:', style: TextStyle(fontSize: 16)),
          TextField(
            controller: _expiryDateController,
            decoration: InputDecoration(
              hintText: 'Escolha a data',
              suffixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            onTap: () => _selectExpiryDate(context),
          ),
        ],
      ),
    );
  }
}
