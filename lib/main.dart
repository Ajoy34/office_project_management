import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ProjectManagementPage(),
        '/viewProjects': (context) => ViewProjectsPage(),
      },
    );
  }
}

class ProjectManagementPage extends StatefulWidget {
  @override
  _ProjectManagementPageState createState() => _ProjectManagementPageState();
}

class _ProjectManagementPageState extends State<ProjectManagementPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _updateController = TextEditingController();
  TextEditingController _engineerController = TextEditingController();
  TextEditingController _technicianController = TextEditingController();

  Future<void> addProject() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('https://scubetech.xyz/projects/dashboard/add-project-elements/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'start_date': _startDateController.text,
          'end_date': _endDateController.text,
          'project_name': _nameController.text,
          'project_update': _updateController.text,
          'assigned_engineer': _engineerController.text,
          'assigned_technician': _technicianController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Project added successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add project')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _startDateController,
                decoration: InputDecoration(labelText: 'Start Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter start date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _endDateController,
                decoration: InputDecoration(labelText: 'End Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter end date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Project Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter project name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _updateController,
                decoration: InputDecoration(labelText: 'Project Update'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter project update';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _engineerController,
                decoration: InputDecoration(labelText: 'Assigned Engineer'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter assigned engineer';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _technicianController,
                decoration: InputDecoration(labelText: 'Assigned Technician'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter assigned technician';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: addProject,
                child: Text('Add Project'),
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/viewProjects');
                },
                child: Text('View Projects'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewProjectsPage extends StatefulWidget {
  @override
  _ViewProjectsPageState createState() => _ViewProjectsPageState();
}

class _ViewProjectsPageState extends State<ViewProjectsPage> {
  Future<List<Project>> fetchProjects() async {
    final response = await http.get(
      Uri.parse('https://scubetech.xyz/projects/dashboard/all-project-elements/'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Project> projects = data.map((json) => Project.fromJson(json)).toList();
      return projects;
    } else {
      throw Exception('Failed to load projects');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Projects'),
      ),
      body: FutureBuilder<List<Project>>(
        future: fetchProjects(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].name),
                  subtitle: Text(snapshot.data![index].projectUpdate),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateProjectPage(project: snapshot.data![index]),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class Project {
  final String id; // Assuming each project has an ID
  final String startDate;
  final String endDate;
  final String name;
  final String projectUpdate;
  final String assignedEngineer;
  final String assignedTechnician;

  Project({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.name,
    required this.projectUpdate,
    required this.assignedEngineer,
    required this.assignedTechnician,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'], // Assuming 'id' is the key for project ID
      startDate: json['start_date'],
      endDate: json['end_date'],
      name: json['project_name'],
      projectUpdate: json['project_update'],
      assignedEngineer: json['assigned_engineer'],
      assignedTechnician: json['assigned_technician'],
    );
  }
}

class UpdateProjectPage extends StatefulWidget {
  final Project project;

  UpdateProjectPage({required this.project});

  @override
  _UpdateProjectPageState createState() => _UpdateProjectPageState();
}

class _UpdateProjectPageState extends State<UpdateProjectPage> {
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _nameController;
  late TextEditingController _updateController;
  late TextEditingController _engineerController;
  late TextEditingController _technicianController;

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController(text: widget.project.startDate);
    _endDateController = TextEditingController(text: widget.project.endDate);
    _nameController = TextEditingController(text: widget.project.name);
    _updateController = TextEditingController(text: widget.project.projectUpdate);
    _engineerController = TextEditingController(text: widget.project.assignedEngineer);
    _technicianController = TextEditingController(text: widget.project.assignedTechnician);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _startDateController,
              decoration: InputDecoration(labelText: 'Start Date'),
            ),
            TextFormField(
              controller: _endDateController,
              decoration: InputDecoration(labelText: 'End Date'),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Project Name'),
            ),
            TextFormField(
              controller: _updateController,
              decoration: InputDecoration(labelText: 'Project Update'),
            ),
            TextFormField(
              controller: _engineerController,
              decoration: InputDecoration(labelText: 'Assigned Engineer'),
            ),
            TextFormField(
              controller: _technicianController,
              decoration: InputDecoration(labelText: 'Assigned Technician'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                final response = await http.put(
                  Uri.parse('https://scubetech.xyz/projects/dashboard/update-project-elements/${widget.project.id}/'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(<String, dynamic>{
                    'start_date': _startDateController.text,
                    'end_date': _endDateController.text,
                    'project_name': _nameController.text,
                    'project_update': _updateController.text,
                    'assigned_engineer': _engineerController.text,
                    'assigned_technician': _technicianController.text,
                  }),
                );

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Project updated successfully')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update project')));
                }
              },
              child: Text('Update Project'),
            ),
          ],
        ),
      ),
    );
  }
}
