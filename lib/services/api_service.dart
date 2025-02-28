import 'dart:convert';
import 'package:finance_app/models/category.dart';
import 'package:http/http.dart' as http;
import '../models/finance_transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/environment_config.dart';

class ApiService {
  // Получение базового URL из конфигурации окружения
  String get baseUrl => EnvironmentConfig.baseApiUrl;

  // Заголовки для запросов
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Вспомогательный метод для логирования запросов
  void _logRequest(String method, String url, Map<String, String> headers,
      [dynamic body]) {
    if (EnvironmentConfig.enableLogging) {
      print('🌐 API Request: $method $url');
      print('🔑 Headers: $headers');
      if (body != null) {
        print('📦 Body: $body');
      }
    }
  }

  // Вспомогательный метод для логирования ответов
  void _logResponse(http.Response response) {
    if (EnvironmentConfig.enableLogging) {
      print('📥 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
    }
  }

  // Авторизация пользователя
  Future<Map<String, dynamic>> login(
      String phoneNumber, String password) async {
    try {
      final url = '$baseUrl/v1/login';
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final body = jsonEncode({
        'username': phoneNumber,
        'password': password,
      });

      _logRequest('POST', url, headers, body);

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(EnvironmentConfig.apiTimeout);

      _logResponse(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Сохраняем токен для последующих запросов
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['data']['access_token']);

        return {
          'success': true,
          'user': data['data']['user'],
          'token': data['data']['access_token']
        };
      } else if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Неверные учетные данные'
        };
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        String errorMessage = 'Ошибка валидации';
        if (data['errors'] != null) {
          List<String> errors = [];
          (data['errors'] as Map<String, dynamic>).forEach((key, value) {
            errors.add((value as List).join('. '));
          });
          errorMessage = errors.join('\n');
        }
        return {'success': false, 'message': errorMessage};
      }

      return {'success': false, 'message': 'Ошибка сервера'};
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'Ошибка соединения: $e'};
    }
  }

  // Регистрация пользователя
  Future<Map<String, dynamic>> register(
      String name, String phoneNumber, String password) async {
    try {
      // По спецификации API, метод регистрации не указан
      // Имплементируйте здесь в соответствии с вашим API
      return {
        'success': false,
        'message': 'Функция регистрации не реализована в API'
      };
    } catch (e) {
      print('Registration error: $e');
      return {'success': false, 'message': 'Ошибка соединения: $e'};
    }
  }

  // Получение информации о пользователе
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/v1/user';

      _logRequest('GET', url, headers);

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(EnvironmentConfig.apiTimeout);

      _logResponse(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Get user info error: $e');
      return null;
    }
  }

  // Обновление информации пользователя
  Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> userData) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/v1/user';

      final body = jsonEncode(userData);

      _logRequest('PUT', url, headers, body);

      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(EnvironmentConfig.apiTimeout);

      _logResponse(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'user': data['data']};
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        String errorMessage = 'Ошибка валидации';
        if (data['errors'] != null) {
          List<String> errors = [];
          (data['errors'] as Map<String, dynamic>).forEach((key, value) {
            errors.add((value as List).join('. '));
          });
          errorMessage = errors.join('\n');
        }
        return {'success': false, 'message': errorMessage};
      }

      return {
        'success': false,
        'message': 'Ошибка обновления данных пользователя'
      };
    } catch (e) {
      print('Update user info error: $e');
      return {'success': false, 'message': 'Ошибка соединения: $e'};
    }
  }

  // Изменение пароля пользователя
  Future<Map<String, dynamic>> changePassword(
      String oldPassword, String newPassword) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/v1/user/password';

      final body = jsonEncode({
        'old_password': oldPassword,
        'password': newPassword,
      });

      _logRequest('POST', url, headers, body);

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(EnvironmentConfig.apiTimeout);

      _logResponse(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['data']['message']};
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        String errorMessage = 'Ошибка валидации';
        if (data['errors'] != null) {
          List<String> errors = [];
          (data['errors'] as Map<String, dynamic>).forEach((key, value) {
            errors.add((value as List).join('. '));
          });
          errorMessage = errors.join('\n');
        }
        return {'success': false, 'message': errorMessage};
      }

      return {'success': false, 'message': 'Ошибка изменения пароля'};
    } catch (e) {
      print('Change password error: $e');
      return {'success': false, 'message': 'Ошибка соединения: $e'};
    }
  }

  // Выход из системы
  Future<bool> logout() async {
    try {
      // В спецификации API нет метода логаута
      // Можно просто очистить токен локально
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      return true;
    } catch (e) {
      print('Logout error: $e');
      return false;
    }
  }

  // Получение категорий
  Future<List<Map<String, dynamic>>> getCategories(int? type) async {
    try {
      final headers = await _getHeaders();
      final url = type != null
          ? '$baseUrl/v1/categories?type=$type'
          : '$baseUrl/v1/categories';

      _logRequest('GET', url, headers);

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(EnvironmentConfig.apiTimeout);

      _logResponse(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((item) => item as Map<String, dynamic>).toList();
        } else if (data is Map && data.containsKey('data')) {
          final List<dynamic> categories = data['data'];
          return categories
              .map((item) => item as Map<String, dynamic>)
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Get categories error: $e');
      return [];
    }
  }

  // Создание категории
  Future<Map<String, dynamic>> createCategory(
      String name, int type, int icon, String color) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/v1/categories';

      final body = jsonEncode({
        'name': name,
        'type': type,
        'icon': icon,
        'color': color,
      });

      _logRequest('POST', url, headers, body);

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(EnvironmentConfig.apiTimeout);

      _logResponse(response);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'category': data['data']};
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        String errorMessage = 'Ошибка валидации';
        if (data['errors'] != null) {
          List<String> errors = [];
          (data['errors'] as Map<String, dynamic>).forEach((key, value) {
            errors.add((value as List).join('. '));
          });
          errorMessage = errors.join('\n');
        }
        return {'success': false, 'message': errorMessage};
      }

      return {'success': false, 'message': 'Ошибка создания категории'};
    } catch (e) {
      print('Create category error: $e');
      return {'success': false, 'message': 'Ошибка соединения: $e'};
    }
  }

  Future<Map<String, dynamic>> updateCategory(Category category) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/v1/categories/${category.id}';

      final body = jsonEncode({
        'name': category.name,
        'type': category.type,
        'icon': category.icon,
        'color': category.color,
      });

      _logRequest('PUT', url, headers, body);

      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(EnvironmentConfig.apiTimeout);

      _logResponse(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'category': data['data']};
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        String errorMessage = 'Ошибка валидации';
        if (data['errors'] != null) {
          List<String> errors = [];
          (data['errors'] as Map<String, dynamic>).forEach((key, value) {
            errors.add((value as List).join('. '));
          });
          errorMessage = errors.join('\n');
        }
        return {'success': false, 'message': errorMessage};
      }

      return {'success': false, 'message': 'Ошибка создания категории'};
    } catch (e) {
      print('Create category error: $e');
      return {'success': false, 'message': 'Ошибка соединения: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteCategory(category) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/v1/categories/$category';

      _logRequest('DELETE', url, headers);

      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(EnvironmentConfig.apiTimeout);

      if (response.statusCode == 200) {
        return {'success': true};
      }
      return {'success': false, 'message': 'Ошибка при удалении категории'};
    } catch (e) {
      print('DELETE category error: $e');
      return {'success': false, 'message': 'Ошибка соединения: $e'};
    }
  }

  // Получение кошельков
  Future<List<Map<String, dynamic>>> getWallets(int type) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/v1/wallet?type=$type';

      _logRequest('GET', url, headers);

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(EnvironmentConfig.apiTimeout);

      _logResponse(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('data')) {
          final List<dynamic> wallets =
              data['data'] is List ? data['data'] : [data['data']];
          return wallets.map((item) => item as Map<String, dynamic>).toList();
        }
      }
      return [];
    } catch (e) {
      print('Get wallets error: $e');
      return [];
    }
  }

  // Создание кошелька
  Future<Map<String, dynamic>> createWallet(String name, int type,
      {int? desiredBalance, String? color, int? icon}) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type'); // Для multipart нужно убрать Content-Type

      final url = '$baseUrl/v1/wallet';

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Добавляем заголовки
      request.headers.addAll(headers);

      // Добавляем поля формы
      request.fields['name'] = name;
      request.fields['type'] = type.toString();

      if (desiredBalance != null) {
        request.fields['desired_balance'] = desiredBalance.toString();
      }

      if (color != null) {
        request.fields['color'] = color;
      }

      if (icon != null) {
        request.fields['icon'] = icon.toString();
      }

      _logRequest('POST', url, headers, request.fields);

      final streamedResponse =
          await request.send().timeout(EnvironmentConfig.apiTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'wallet': data['data']};
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        String errorMessage = 'Ошибка валидации';
        if (data['errors'] != null) {
          List<String> errors = [];
          (data['errors'] as Map<String, dynamic>).forEach((key, value) {
            errors.add((value as List).join('. '));
          });
          errorMessage = errors.join('\n');
        }
        return {'success': false, 'message': errorMessage};
      }

      return {'success': false, 'message': 'Ошибка создания кошелька'};
    } catch (e) {
      print('Create wallet error: $e');
      return {'success': false, 'message': 'Ошибка соединения: $e'};
    }
  }

  // Получение транзакций
  Future<List<FinanceTransaction>> getTransactions({
    int? walletId,
    int? categoryId,
    String? type,
    String? walletType,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? amountFrom,
    int? amountTo,
  }) async {
    try {
      final headers = await _getHeaders();

      // Формируем URL с параметрами
      String url = '$baseUrl/v1/wallet-transactions';
      List<String> queryParams = [];

      if (walletId != null) queryParams.add('wallet_id=$walletId');
      if (categoryId != null) queryParams.add('category_id=$categoryId');
      if (type != null) queryParams.add('type=$type');
      if (walletType != null) queryParams.add('wallet_type=$walletType');

      if (dateFrom != null) {
        queryParams.add('date_from=${dateFrom.toIso8601String()}');
      }

      if (dateTo != null) {
        queryParams.add('date_to=${dateTo.toIso8601String()}');
      }

      if (amountFrom != null) queryParams.add('amount_from=$amountFrom');
      if (amountTo != null) queryParams.add('amount_to=$amountTo');

      // Добавляем параметры сортировки
      queryParams.add('order[field]=date&order[direction]=desc');

      if (queryParams.isNotEmpty) {
        url += '?' + queryParams.join('&');
      }

      _logRequest('GET', url, headers);

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(EnvironmentConfig.apiTimeout);

      _logResponse(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('data')) {
          final List<dynamic> transactions = data['data'];
          return transactions.map((item) => _parseTransaction(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Get transactions error: $e');
      return [];
    }
  }

  // Создание транзакции
  Future<Map<String, dynamic>> createTransaction({
    required int walletId,
    required int amount,
    required String type,
    required String date,
    String? name,
    int? categoryId,
    String? comment,
    bool? templateTransaction,
    bool? regularTransaction,
    int? days,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/v1/wallet-transactions';

      Map<String, dynamic> body = {
        'wallet_id': walletId,
        'amount': amount,
        'type': type,
        'date': date,
      };

      if (name != null) body['name'] = name;
      if (categoryId != null) body['category_id'] = categoryId;
      if (comment != null) body['comment'] = comment;
      if (templateTransaction != null)
        body['template_transaction'] = templateTransaction;
      if (regularTransaction != null)
        body['regular_transaction'] = regularTransaction;
      if (days != null) body['days'] = days;

      _logRequest('POST', url, headers, jsonEncode(body));

      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(EnvironmentConfig.apiTimeout);

      _logResponse(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'transaction': data['data']};
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        String errorMessage = 'Ошибка валидации';
        if (data['errors'] != null) {
          List<String> errors = [];
          (data['errors'] as Map<String, dynamic>).forEach((key, value) {
            errors.add((value as List).join('. '));
          });
          errorMessage = errors.join('\n');
        }
        return {'success': false, 'message': errorMessage};
      }

      return {'success': false, 'message': 'Ошибка создания транзакции'};
    } catch (e) {
      print('Create transaction error: $e');
      return {'success': false, 'message': 'Ошибка соединения: $e'};
    }
  }

  // Обновление транзакции
  Future<Map<String, dynamic>> updateTransaction(
    int transactionId, {
    String? name,
    int? amount,
    String? comment,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/v1/wallet-transactions/$transactionId';

      Map<String, dynamic> body = {};

      if (name != null) body['name'] = name;
      if (amount != null) body['amount'] = amount;
      if (comment != null) body['comment'] = comment;

      _logRequest('PUT', url, headers, jsonEncode(body));

      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(EnvironmentConfig.apiTimeout);

      _logResponse(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'transaction': data['data']};
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        String errorMessage = 'Ошибка валидации';
        if (data['errors'] != null) {
          List<String> errors = [];
          (data['errors'] as Map<String, dynamic>).forEach((key, value) {
            errors.add((value as List).join('. '));
          });
          errorMessage = errors.join('\n');
        }
        return {'success': false, 'message': errorMessage};
      }

      return {'success': false, 'message': 'Ошибка обновления транзакции'};
    } catch (e) {
      print('Update transaction error: $e');
      return {'success': false, 'message': 'Ошибка соединения: $e'};
    }
  }

  // Удаление транзакции
  Future<bool> deleteTransaction(int transactionId) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/v1/wallet-transactions/$transactionId';

      _logRequest('DELETE', url, headers);

      final response = await http
          .delete(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(EnvironmentConfig.apiTimeout);

      _logResponse(response);

      return response.statusCode == 200;
    } catch (e) {
      print('Delete transaction error: $e');
      return false;
    }
  }

  // Получение данных для круговой диаграммы расходов/доходов
  Future<Map<String, dynamic>> getCircleDiagramData(String period,
      {String? type}) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/v1/analytics/circle-diagram?period=$period';

      if (type != null) {
        url += '&type=$type';
      }

      _logRequest('GET', url, headers);

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(EnvironmentConfig.apiTimeout);

      _logResponse(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {};
    } catch (e) {
      print('Get circle diagram data error: $e');
      return {};
    }
  }

  // Получение общей суммы расходов/доходов за период
  Future<String> getTotalAmount(String period, {String? type}) async {
    try {
      final headers = await _getHeaders();
      String url = '$baseUrl/v1/analytics/total?period=$period';

      if (type != null) {
        url += '&type=$type';
      }

      _logRequest('GET', url, headers);

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(EnvironmentConfig.apiTimeout);

      _logResponse(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['sum'] ?? '0';
      }

      return '0';
    } catch (e) {
      print('Get total amount error: $e');
      return '0';
    }
  }

  // Преобразование JSON в объект FinanceTransaction
  FinanceTransaction _parseTransaction(Map<String, dynamic> json) {
    // Определяем тип транзакции
    TransactionType transactionType =
        json['type'] == 1 || json['type_def'] == 'income'
            ? TransactionType.income
            : TransactionType.expense;

    return FinanceTransaction(
      id: json['id'].toString(),
      title: json['name'] ?? '',
      amount: json['amount'] is int
          ? json['amount'].toDouble()
          : double.parse(json['amount'].toString()),
      date: DateTime.parse(json['date']),
      category: Category.fromMap(json['category'] ?? {'name': 'Без категории'}),
      type: transactionType,
      note: json['comment'],
    );
  }

  // Подготовка данных для отправки на сервер
  Map<String, dynamic> _prepareTransactionData(FinanceTransaction transaction) {
    return {
      'name': transaction.title,
      'amount': transaction.amount.toInt(),
      'date': transaction.date.toIso8601String(),
      'type': transaction.type == TransactionType.income ? '1' : '2',
      'comment': transaction.note,
    };
  }

  // Добавьте этот метод в класс ApiService

  // Загрузка банковской выписки
  Future<Map<String, dynamic>> uploadBankStatement(
    String filePath,
    String fileName,
    String fileType,
  ) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type'); // Для multipart нужно убрать Content-Type

      final url = '$baseUrl/v1/bank-statements/upload';

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Добавляем заголовки
      request.headers.addAll(headers);

      // Добавляем файл
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: fileName,
      ));

      _logRequest('POST', url, headers, 'File upload: $fileName ($fileType)');

      final streamedResponse =
          await request.send().timeout(EnvironmentConfig.apiTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        String errorMessage = 'Ошибка валидации';
        if (data['errors'] != null) {
          List<String> errors = [];
          (data['errors'] as Map<String, dynamic>).forEach((key, value) {
            errors.add((value as List).join('. '));
          });
          errorMessage = errors.join('\n');
        }
        return {'success': false, 'message': errorMessage};
      }

      return {
        'success': false,
        'message': 'Ошибка загрузки банковской выписки'
      };
    } catch (e) {
      print('Upload bank statement error: $e');
      return {'success': false, 'message': 'Ошибка соединения: $e'};
    }
  }

  // Получение списка загруженных банковских выписок
  Future<List<Map<String, dynamic>>> getBankStatements() async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/v1/bank-statements';

      _logRequest('GET', url, headers);

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(EnvironmentConfig.apiTimeout);

      _logResponse(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('data')) {
          final List<dynamic> statements = data['data'];
          return statements
              .map((item) => item as Map<String, dynamic>)
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Get bank statements error: $e');
      return [];
    }
  }
}
