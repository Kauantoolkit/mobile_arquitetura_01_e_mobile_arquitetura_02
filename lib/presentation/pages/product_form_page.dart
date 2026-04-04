import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/product_state.dart';

/// Tela de formulário para criar ou editar produtos.
/// Reutilizável: selectedProduct == null → CREATE, else → UPDATE.
class ProductFormPage extends StatefulWidget {
  final ProductViewModel viewModel;

  const ProductFormPage({super.key, required this.viewModel});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _category;

  @override
  void initState() {
    super.initState();
    // Preenche form se editando
    final selected = widget.viewModel.state.value.selectedProduct;
    if (selected != null) {
      _titleController.text = selected.title;
      _priceController.text = selected.price.toString();
      _imageController.text = selected.image;
      _descriptionController.text = selected.description ?? '';
      _category = selected.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    widget.viewModel.clearFormError();

    final selectedProduct = widget.viewModel.state.value.selectedProduct;
    final product = Product(
      id: selectedProduct?.id ?? 0,
      title: _titleController.text,
      price: double.parse(_priceController.text),
      image: _imageController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      category: _category?.isEmpty ?? true ? null : _category,
    );

    print('[FORM] _submit: selectedProduct=${selectedProduct?.id} | product.id=${product.id} | title="${product.title}"');

    try {
      if (selectedProduct == null) {
        print('[FORM] modo CREATE');
        await widget.viewModel.createProduct(product);
        print('[FORM] createProduct retornou — chamando pop');
        if (mounted) {
          Navigator.pop(context, true); // Sucesso
        }
      } else {
        print('[FORM] modo UPDATE (id=${selectedProduct.id})');
        await widget.viewModel.updateProduct(product);
        print('[FORM] updateProduct retornou — chamando pop');
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print('[FORM] EXCEPTION capturada: $e');
      // Erro já tratado no ViewModel (formError)
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.viewModel.state.value.formError ?? 'Erro desconhecido',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.viewModel.state.value.selectedProduct != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Produto' : 'Novo Produto')),
      body: ValueListenableBuilder<ProductState>(
        valueListenable: widget.viewModel.state,
        builder: (context, state, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  /// Título
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Título obrigatório';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  /// Preço
                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Preço (R\$) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      prefixText: 'R\$ ',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Preço obrigatório';
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) return 'Preço inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  /// Imagem URL
                  TextFormField(
                    controller: _imageController,
                    decoration: const InputDecoration(
                      labelText: 'URL da Imagem',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.image),
                      hintText: 'https://example.com/image.jpg',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'URL da imagem obrigatória';
                      if (!value.startsWith('http'))
                        return 'URL deve começar com http';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  /// Categoria
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'electronics',
                        child: Text('Eletrônicos'),
                      ),
                      DropdownMenuItem(value: 'jewelery', child: Text('Joias')),
                      DropdownMenuItem(
                        value: 'men\'s clothing',
                        child: Text('Roupas Masculinas'),
                      ),
                      DropdownMenuItem(
                        value: 'women\'s clothing',
                        child: Text('Roupas Femininas'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _category = value),
                  ),
                  const SizedBox(height: 16),

                  /// Descrição
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                      alignLabelWithHint: true,
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// Botões
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.viewModel.state.value.isSubmitting
                              ? null
                              : _submit,
                          icon: widget.viewModel.state.value.isSubmitting
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            widget.viewModel.state.value.isSubmitting
                                ? 'Salvando...'
                                : 'Salvar',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: const Text('Cancelar'),
                        ),
                      ),
                    ],
                  ),

                  /// Erro do formulário
                  if (widget.viewModel.state.value.formError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.viewModel.state.value.formError!,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
