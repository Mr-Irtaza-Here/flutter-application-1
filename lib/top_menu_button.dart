import 'package:flutter/material.dart';
import 'add_engineer_logic.dart';
import 'delete_engineer_logic.dart';
import 'add_client_logic.dart';
import 'delete_client_logic.dart';
import 'add_fuel_cost.dart';

class TopMenuButton extends StatelessWidget {
  const TopMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.menu,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class OperationsSideMenu extends StatefulWidget {
  final Function(String) onEngineerAdded;
  final VoidCallback onEngineersUpdated;
  final Function(String) onClientAdded;
  final VoidCallback onClientsUpdated;
  final Function(String) onFuelCostAdded;

  const OperationsSideMenu({
    super.key,
    required this.onEngineerAdded,
    required this.onEngineersUpdated,
    required this.onClientAdded,
    required this.onClientsUpdated,
    required this.onFuelCostAdded,
  });

  @override
  State<OperationsSideMenu> createState() => _OperationsSideMenuState();
}

enum MenuState { main, engineers, clients }

class _OperationsSideMenuState extends State<OperationsSideMenu> {
  MenuState _currentState = MenuState.main;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String title = 'Operations Menu';
    Color color = Colors.blue;
    
    if (_currentState == MenuState.engineers) {
      title = 'Manage Engineers';
      color = Colors.teal;
    } else if (_currentState == MenuState.clients) {
      title = 'Manage Clients';
      color = Colors.green; // Adjusted to distinct color if needed, or keep blue
    }

    return Container(
      height: 120,
      width: double.infinity,
      color: color,
      alignment: Alignment.center,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentState) {
      case MenuState.main:
        return _buildMainMenu();
      case MenuState.engineers:
        return _buildEngineersMenu();
      case MenuState.clients:
        return _buildClientsMenu();
    }
  }

  Widget _buildMainMenu() {
    return Column(
      children: [
        _buildMenuButton(
          icon: Icons.engineering_rounded,
          label: 'Manage Engineers',
          color: Colors.teal,
          onPressed: () {
            setState(() {
              _currentState = MenuState.engineers;
            });
          },
        ),
        _buildMenuButton(
          icon: Icons.people_alt_rounded,
          label: 'Manage Clients',
          color: Colors.blue,
          onPressed: () {
            setState(() {
              _currentState = MenuState.clients;
            });
          },
        ),
        _buildMenuButton(
          icon: Icons.local_gas_station_rounded,
          label: 'Add Fuel-Cost',
          color: Colors.orange,
          onPressed: () {
             AddFuelCostLogic().showAddFuelCostDialog(
                context,
                widget.onFuelCostAdded,
              );
          },
        ),
        _buildCloseButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEngineersMenu() {
    return Column(
      children: [
        _buildMenuButton(
          icon: Icons.person_add_rounded,
          label: 'Add Engineer',
          color: Colors.green,
          onPressed: () {
             AddEngineerLogic().showAddEngineerDialog(
                context,
                widget.onEngineerAdded,
              );
          },
        ),
        _buildMenuButton(
          icon: Icons.person_remove_rounded,
          label: 'Delete Engineer',
          color: Colors.red,
          onPressed: () {
             DeleteEngineerLogic().showDeleteEngineerDialog(
                context,
                widget.onEngineersUpdated,
              );
          },
        ),
        _buildBackButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildClientsMenu() {
    return Column(
      children: [
         _buildMenuButton(
          icon: Icons.person_add_rounded,
          label: 'Add Client',
          color: Colors.green,
          onPressed: () {
             AddClientLogic().showAddClientDialog(
                context,
                widget.onClientAdded,
              );
          },
        ),
        _buildMenuButton(
          icon: Icons.person_remove_rounded,
          label: 'Delete Client',
          color: Colors.red,
          onPressed: () {
             DeleteClientLogic().showDeleteClientDialog(
                context,
                widget.onClientsUpdated,
              );
          },
        ),
        _buildBackButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: color),
          label: Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _currentState = MenuState.main;
            });
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          label: const Text(
            'Back',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
             alignment: Alignment.center,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
     return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            elevation: 2,
            // Matching shape with others for consistency
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Close',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
