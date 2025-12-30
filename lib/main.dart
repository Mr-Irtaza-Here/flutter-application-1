import 'package:flutter/material.dart';
import 'top_menu_button.dart';
import 'engineer_names.dart';
import 'calendar.dart';
import 'cost.dart';
import 'category.dart';
import 'type.dart';
import 'client.dart';
import 'status.dart';
import 'car_bike_no.dart';
import 'description.dart';
import 'fuel_cost.dart';
import 'time_consumed.dart';
import 'start_end_distance.dart';
import 'home_bottom_buttons.dart';
import 'screen_switch.dart';
import 'add_engineer_logic.dart';
import 'add_client_logic.dart';
import 'add_fuel_cost.dart';
import 'storage_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Entry Form',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ScreenSwitch(),
    );
  }
}

class DataEntryPage extends StatefulWidget {
  const DataEntryPage({super.key});

  @override
  State<DataEntryPage> createState() => _DataEntryPageState();
}

class _DataEntryPageState extends State<DataEntryPage> {
  // For now, empty list - engineers will be added later
  // Engineers List
  List<String> _engineersList = [];
  List<String> _selectedEngineers = [];
  DateTime? _selectedDate;
  String? _cost;
  String? _selectedCategory;
  String? _selectedType;
  // For now, empty list - clients will be added later
  List<String> _clientsList = [];
  String? _selectedClient;
  String? _selectedStatus;
  String? _carBikeNo;
  String? _description;
  String? _fuelCost;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  double _totalTime = 0.0;
  String? _startLocation;
  String? _endLocation;
  String? _distance;

  @override
  void initState() {
    super.initState();
    _loadEngineers();
    _loadClients();
    _loadFuelCost();
  }

  Future<void> _loadEngineers() async {
    final engineers = await AddEngineerLogic.getEngineers();
    setState(() {
      _engineersList = engineers;
    });
  }

  void _onEngineerAdded(String name) {
    setState(() {
      if (!_engineersList.contains(name)) {
        _engineersList.add(name);
      }
    });
  }

  Future<void> _loadClients() async {
    final clients = await AddClientLogic.getClients();
    setState(() {
      _clientsList = clients;
    });
  }

  void _onClientAdded(String name) {
    setState(() {
      if (!_clientsList.contains(name)) {
        _clientsList.add(name);
      }
    });
  }

  Future<void> _loadFuelCost() async {
    final savedFuelCost = await AddFuelCostLogic.getFuelCost();
    if (savedFuelCost != null) {
      setState(() {
        _fuelCost = savedFuelCost;
      });
    }
  }

  void _onFuelCostAdded(String value) {
    setState(() {
      _fuelCost = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: OperationsSideMenu(
        onEngineerAdded: _onEngineerAdded,
        onEngineersUpdated: () {
          _loadEngineers();
        },
        onClientAdded: _onClientAdded,
        onClientsUpdated: () {
          _loadClients();
        },
        onFuelCostAdded: _onFuelCostAdded,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top Row with Heading centered and Menu Button on right (FIXED)
              Row(
                children: [
                  // Empty space on left to balance the menu button
                  const SizedBox(width: 48),
                  // Heading centered
                  const Expanded(
                    child: Text(
                      'Data Entry Form',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Menu Button on right
                  // Menu Button on right
                  const TopMenuButton(),
                ],
              ),
              const SizedBox(height: 24),
              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Engineer Names Field
                      EngineerNamesField(
                        engineersList: _engineersList,
                        selectedEngineers: _selectedEngineers,
                        onEngineersSelected: (engineers) {
                          setState(() {
                            _selectedEngineers = engineers;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Date Picker Field
                      DatePickerField(
                        selectedDate: _selectedDate,
                        onDateSelected: (date) {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Cost Input Field
                      CostInputField(
                        cost: _cost,
                        onCostChanged: (cost) {
                          setState(() {
                            _cost = cost;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Category Field
                      CategoryField(
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Type Field
                      TypeField(
                        selectedType: _selectedType,
                        onTypeSelected: (type) {
                          setState(() {
                            _selectedType = type;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Client Field
                      ClientField(
                        clientsList: _clientsList,
                        selectedClient: _selectedClient,
                        onClientSelected: (client) {
                          setState(() {
                            _selectedClient = client;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Status Field
                      StatusField(
                        selectedStatus: _selectedStatus,
                        onStatusSelected: (status) {
                          setState(() {
                            _selectedStatus = status;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Car/Bike No Field
                      CarBikeNoField(
                        number: _carBikeNo,
                        onNumberChanged: (number) {
                          setState(() {
                            _carBikeNo = number;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Description Field
                      DescriptionField(
                        description: _description,
                        onDescriptionChanged: (description) {
                          setState(() {
                            _description = description;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Fuel Cost Field
                      FuelCostField(
                        fuelCost: _fuelCost,
                        onFuelCostChanged: (cost) {
                          setState(() {
                            _fuelCost = cost;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Time Consumed Field
                      TimeConsumedField(
                        startTime: _startTime,
                        endTime: _endTime,
                        onTimeChanged: (start, end, duration) {
                          setState(() {
                            _startTime = start;
                            _endTime = end;
                            _totalTime = duration;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Start/End Distance Field
                      StartEndDistanceField(
                        startLocation: _startLocation,
                        endLocation: _endLocation,
                        distance: _distance,
                        onStartLocationChanged: (val) {
                          setState(() {
                            _startLocation = val;
                          });
                        },
                        onEndLocationChanged: (val) {
                          setState(() {
                            _endLocation = val;
                          });
                        },
                        onDistanceChanged: (val) {
                          setState(() {
                            _distance = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Home Bottom Buttons
                      HomeBottomButtons(
                        onOpenMaps: () {
                          // TODO: Implement Open Maps
                          debugPrint('Open Maps Clicked');
                        },
                        onAddData: () async {
                          // Validate all required fields are filled
                          if (_selectedEngineers.isEmpty ||
                              _selectedDate == null ||
                              _cost == null || _cost!.isEmpty ||
                              _selectedCategory == null || _selectedCategory!.isEmpty ||
                              _selectedType == null || _selectedType!.isEmpty ||
                              _selectedClient == null || _selectedClient!.isEmpty ||
                              _selectedStatus == null || _selectedStatus!.isEmpty ||
                              _carBikeNo == null || _carBikeNo!.isEmpty ||
                              _description == null || _description!.isEmpty ||
                              _fuelCost == null || _fuelCost!.isEmpty ||
                              _startTime == null ||
                              _endTime == null ||
                              _startLocation == null || _startLocation!.isEmpty ||
                              _endLocation == null || _endLocation!.isEmpty ||
                              _distance == null || _distance!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fill all the Entries'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          
                          // Create storage entry from all form data
                          final entry = StorageEntry(
                            engineerName: _selectedEngineers.join(', '),
                            date: _selectedDate?.toString().split(' ')[0],
                            cost: _cost,
                            category: _selectedCategory,
                            type: _selectedType,
                            client: _selectedClient,
                            status: _selectedStatus,
                            carBikeNo: _carBikeNo,
                            description: _description,
                            fuelCost: _fuelCost,
                            startTime: _startTime?.format(context),
                            endTime: _endTime?.format(context),
                            totalTime: _totalTime > 0 ? '${_totalTime.toStringAsFixed(2)} hrs' : null,
                            startLocation: _startLocation,
                            endLocation: _endLocation,
                            distance: _distance,
                            timestamp: DateTime.now().toIso8601String(),
                          );
                          await StorageLogic.saveEntry(entry);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Data saved to storage!'),
                                backgroundColor: Colors.teal,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        onCheckUpdates: () {
                          // TODO: Implement Check for Updates
                          debugPrint('Check Updates Clicked');
                        },
                      ),
                      const SizedBox(height: 32), // Extra space at bottom
                      // Rest of the page content can go here
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

