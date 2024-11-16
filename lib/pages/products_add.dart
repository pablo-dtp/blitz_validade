import 'package:http/http.dart' as http;
import 'imports.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _packagingController = TextEditingController(text: '1');
  final TextEditingController _expiryDateController = TextEditingController();
  
  late double firstContainerTopPosition;
  late double firstContainerLeftPosition;
  late double firstContainerRightPosition;

  String _productName = '';
  String _productDescription = '';
  String _productBarcode = '';
  String _expiryDate = '';

  bool _isProductFound = false;
  bool _isQuantityFilled = false;
  bool _isPackagingFilled = false;
  bool _isDateSelected = false;

  Future<void> _fetchProductInfo(String barcode) async {
    final url = '${dotenv.env['API_BASE_URL']}/get_product';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({'codigo_barras': barcode}),
        headers: {'Content-Type': 'application/json'},
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
    final DateTime minimumDate = now.add(Duration(days: 3));

    final DateTime initialDate = now.isBefore(minimumDate) ? minimumDate : now;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minimumDate,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _expiryDate = "${pickedDate.toLocal()}".split(' ')[0];
        _expiryDateController.text = _expiryDate;
        _isDateSelected = true;
      });
    }
  }

  void _checkFields() {
    setState(() {
      _isQuantityFilled = _quantityController.text.isNotEmpty;
      _isPackagingFilled = _packagingController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;

    // Agora calculamos a posição do primeiro container a 5% abaixo da AppBar
    firstContainerTopPosition = appBarHeight + (screenHeight * 0.02); // 5% abaixo da AppBar

    firstContainerLeftPosition = screenWidth * 0.05; // 5% da largura da tela
    firstContainerRightPosition = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Center(
          child: Image.asset(
            'assets/logo.png',
            width: 80,
            height: 80,
          ),
        ),
      ),
      body: Container(
        width: double.infinity, // Garante que o container ocupe toda a largura
        height: screenHeight, // Garante que o container ocupe toda a altura da tela
        decoration: const BoxDecoration(
          color: AppColors.primaryColor, // Cor de fundo
        ),
        child: Stack(
          children: [
            // Container do código de barras
            Positioned(
              top: firstContainerTopPosition, // Agora a posição é 5% abaixo da AppBar
              left: firstContainerLeftPosition,
              right: firstContainerRightPosition,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 15),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _barcodeController,
                        decoration: InputDecoration(
                          labelText: 'LER CÓDIGO DE BARRAS',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.barcode_reader, size: 25, color: Colors.black),
                      onPressed: () {
                        final barcode = _barcodeController.text;
                        if (barcode.isNotEmpty) {
                          _fetchProductInfo(barcode);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Container das informações do produto
            Positioned(
              top: firstContainerTopPosition + 100, // 70 pixels abaixo do primeiro container
              left: firstContainerLeftPosition,
              right: firstContainerRightPosition,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField('Produto', _productName),
                    _buildField('Descrição', _productDescription),
                    _buildField('Código de Barras', _productBarcode),
                    _buildQuantityAndPackagingField(),
                    _buildDateField(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: (_isProductFound && _isQuantityFilled && _isPackagingFilled && _isDateSelected)
                          ? () async {
                              final Map<String, dynamic> productData = {
                                'produto': int.tryParse(_productName) ?? 0,
                                'descricao': _productDescription,
                                'codigo_barras': _productBarcode,
                                'quantidade': int.tryParse(_quantityController.text) ?? 1,
                                'embalagem': int.tryParse(_packagingController.text) ?? 1,
                                'data_validade': _expiryDate,
                              };

                              final response = await http.post(
                                Uri.parse('${dotenv.env['API_BASE_URL']}/add_validade'),
                                headers: {'Content-Type': 'application/json'},
                                body: json.encode(productData),
                              );

                              if (response.statusCode == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Produto registrado com sucesso!')),
                                );
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
            ),
          ],
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
          Divider(color: const Color.fromARGB(255, 127, 121, 121)),
        ],
      ),
    );
  }

  Widget _buildQuantityAndPackagingField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quantidades e Embalagens:', style: TextStyle(fontSize: 16)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    hintText: 'Quantidade',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (text) => _checkFields(),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _packagingController,
                  decoration: InputDecoration(
                    hintText: 'Embalagem',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (text) => _checkFields(),
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
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Data de Validade:', style: TextStyle(fontSize: 16)),
          TextField(
            controller: _expiryDateController,
            decoration: InputDecoration(
              hintText: 'Escolher data',
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
