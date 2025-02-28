import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:finance_app/theme/app_theme.dart';
import 'package:finance_app/services/api_service.dart';
import 'package:finance_app/providers/transaction_provider.dart';

class BankStatementScreen extends StatefulWidget {
  const BankStatementScreen({Key? key}) : super(key: key);

  @override
  _BankStatementScreenState createState() => _BankStatementScreenState();
}

class _BankStatementScreenState extends State<BankStatementScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _statements = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _error;
  String? _selectedFilePath;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    _loadStatements();
  }

  Future<void> _loadStatements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final statements = await _apiService.getBankStatements();

      setState(() {
        _statements = statements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки списка выписок: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls', 'pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка выбора файла: $e';
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFilePath == null) {
      setState(() {
        _error = 'Сначала выберите файл для загрузки';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _error = null;
    });

    try {
      final fileType = path.extension(_selectedFilePath!).replaceAll('.', '');

      final result = await _apiService.uploadBankStatement(
        _selectedFilePath!,
        _selectedFileName!,
        fileType,
      );

      if (result['success']) {
        // Обновляем список и сбрасываем выбранный файл
        await _loadStatements();

        // Обновляем список транзакций, если загрузка успешна
        await Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();

        setState(() {
          _selectedFilePath = null;
          _selectedFileName = null;
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Выписка успешно загружена'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _error = result['message'] ?? 'Ошибка загрузки файла';
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка при загрузке файла: $e';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Банковские выписки'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadStatements,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Блок загрузки выписки
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Загрузить новую выписку',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: AppTheme.paddingM),
                        Text(
                          'Поддерживаемые форматы: CSV, XLSX, XLS, PDF',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: AppTheme.paddingM),

                        // Отображение выбранного файла
                        if (_selectedFilePath != null)
                          Container(
                            padding: EdgeInsets.all(AppTheme.paddingS),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusS),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.description,
                                  color: AppTheme.primaryColor,
                                ),
                                SizedBox(width: AppTheme.paddingS),
                                Expanded(
                                  child: Text(
                                    _selectedFileName ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedFilePath = null;
                                      _selectedFileName = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: AppTheme.paddingM),

                        // Кнопки выбора и загрузки файла
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.file_upload),
                                label: Text('Выбрать файл'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                ),
                                onPressed: _isUploading ? null : _selectFile,
                              ),
                            ),
                            SizedBox(width: AppTheme.paddingM),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.cloud_upload),
                                label: Text(_isUploading ? 'Загрузка...' : 'Загрузить'),
                                onPressed: _isUploading ? null : _uploadFile,
                              ),
                            ),
                          ],
                        ),

                        // Отображение ошибки
                        if (_error != null)
                          Padding(
                            padding: EdgeInsets.only(top: AppTheme.paddingM),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(AppTheme.paddingM),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                                border: Border.all(
                                  color: Colors.red[300]!,
                                ),
                              ),
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  color: Colors.red[800],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppTheme.paddingL),

                // Список ранее загруженных выписок
                Text(
                  'Загруженные выписки',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: AppTheme.paddingM),

                if (_isLoading)
                  Center(child: CircularProgressIndicator())
                else if (_statements.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _statements.length,
                    itemBuilder: (context, index) => _buildStatementItem(_statements[index]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppTheme.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: AppTheme.paddingM),
            Text(
              'У вас пока нет загруженных выписок',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.paddingS),
            Text(
              'Загрузите выписку из вашего банка, чтобы автоматически импортировать транзакции',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatementItem(Map<String, dynamic> statement) {
    // Форматирование даты загрузки
    String dateUploaded = statement['created_at'] ?? 'Неизвестная дата';

    // Определение типа файла и иконки
    IconData fileIcon;
    String fileType = statement['file_type']?.toString().toLowerCase() ?? '';

    if (fileType.contains('csv')) {
      fileIcon = Icons.table_chart;
    } else if (fileType.contains('xls')) {
      fileIcon = Icons.table_view;
    } else if (fileType.contains('pdf')) {
      fileIcon = Icons.picture_as_pdf;
    } else {
      fileIcon = Icons.description;
    }

    // Получение имени файла
    String fileName = statement['file_name'] ?? 'Выписка';

    // Определение статуса обработки
    String status = statement['status'] ?? 'pending';
    String statusText;
    Color statusColor;

    switch (status) {
      case 'processed':
        statusText = 'Обработана';
        statusColor = Colors.green;
        break;
      case 'failed':
        statusText = 'Ошибка';
        statusColor = Colors.red;
        break;
      case 'pending':
      default:
        statusText = 'В обработке';
        statusColor = Colors.orange;
    }

    return Card(
      margin: EdgeInsets.only(bottom: AppTheme.paddingS),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppTheme.paddingM),
        child: Row(
          children: [
            // Иконка типа файла
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              child: Icon(
                fileIcon,
                color: Colors.grey[800],
                size: 20,
              ),
            ),
            SizedBox(width: AppTheme.paddingM),

            // Информация о выписке
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        dateUploaded,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}