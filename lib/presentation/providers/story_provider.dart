import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/state/api_state.dart';
import '../../data/models/story_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';

class StoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  ApiState<List<Story>> _storiesState = const ApiInitial();
  ApiState<bool> _addStoryState = const ApiInitial();
  List<Story> _stories = [];

  ApiState<List<Story>> get storiesState => _storiesState;
  ApiState<bool> get addStoryState => _addStoryState;
  List<Story> get stories => _stories;

  Future<void> getStories() async {
    _storiesState = const ApiLoading();
    notifyListeners();

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        _storiesState = const ApiError('Token not found');
        notifyListeners();
        return;
      }

      final stories = await _apiService.getStories(token);
      _stories = stories;
      _storiesState = ApiSuccess(stories);
      notifyListeners();
    } catch (e) {
      _storiesState = ApiError(e.toString());
      notifyListeners();
    }
  }

  Future<void> addStory(String description, File imageFile,
      {double? lat, double? lon}) async {
    _addStoryState = const ApiLoading();
    notifyListeners();

    try {
      final token = await StorageService.getToken();
      if (token == null) {
        _addStoryState = const ApiError('Token not found');
        notifyListeners();
        return;
      }

      final success = await _apiService.addStory(token, description, imageFile,
          lat: lat, lon: lon);
      _addStoryState = ApiSuccess(success);

      if (success) {
        // Refresh stories after successful upload
        await getStories();
      }

      notifyListeners();
    } catch (e) {
      _addStoryState = ApiError(e.toString());
      notifyListeners();
    }
  }

  void resetAddStoryState() {
    _addStoryState = const ApiInitial();
    notifyListeners();
  }
}
