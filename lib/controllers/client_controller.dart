import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../services/database_service.dart';
import '../core/utils/status_calculator.dart';

class ClientController extends ChangeNotifier {
  List<ClientModel> _clients = [];
  bool _isLoading = false;

  List<ClientModel> get clients => _clients;
  bool get isLoading => _isLoading;

  Future<void> loadClients(String userId, {bool isAdmin = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (isAdmin) {
        _clients = await DatabaseService.getAllClients();
      } else {
        _clients = await DatabaseService.getClientsByUser(userId);
      }
      
      // Get admin settings for status calculation
      final settings = await DatabaseService.getAdminSettings();
      final statusSettings = settings['clientStatusSettings'] ?? {};
      final greenDays = statusSettings['greenDays'] ?? 30;
      final yellowDays = statusSettings['yellowDays'] ?? 30;
      final redDays = statusSettings['redDays'] ?? 1;
      
      // Update status for all clients
      for (int i = 0; i < _clients.length; i++) {
        final updatedClient = _clients[i].copyWith(
          status: StatusCalculator.calculateStatus(
            _clients[i].entryDate,
            greenDays: greenDays,
            yellowDays: yellowDays,
            redDays: redDays,
          ),
          daysRemaining: StatusCalculator.calculateDaysRemaining(_clients[i].entryDate),
        );
        _clients[i] = updatedClient;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateClientStatus(String clientId, ClientStatus status) async {
    try {
      await DatabaseService.updateClientStatus(clientId, status);
      final index = _clients.indexWhere((client) => client.id == clientId);
      if (index != -1) {
        _clients[index] = _clients[index].copyWith(
          status: status,
          hasExited: status == ClientStatus.white,
        );
        notifyListeners();
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteClient(String clientId) async {
    try {
      await DatabaseService.deleteClient(clientId);
      _clients.removeWhere((client) => client.id == clientId);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> refreshClients(String userId, {bool isAdmin = false}) async {
    await loadClients(userId, isAdmin: isAdmin);
  }

  List<ClientModel> getClientsByStatus(ClientStatus status) {
    return _clients.where((client) => client.status == status).toList();
  }

  List<ClientModel> getExpiringClients(int days) {
    return _clients.where((client) => 
      client.daysRemaining <= days && 
      client.daysRemaining >= 0 && 
      !client.hasExited
    ).toList();
  }

  int getClientsCount() => _clients.length;
  
  int getActiveClientsCount() => _clients.where((c) => !c.hasExited).length;
  
  int getExitedClientsCount() => _clients.where((c) => c.hasExited).length;
}
