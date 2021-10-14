class Actor {
  int? page;
  List<Results>? results;
  int? totalPages;
  int? totalResults;

  Actor({this.page, this.results, this.totalPages, this.totalResults});

  Actor.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
    totalPages = json['total_pages'];
    totalResults = json['total_results'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    data['total_pages'] = totalPages;
    data['total_results'] = totalResults;
    return data;
  }
}

class Results {
  bool? adult;
  int? gender;
  String? name;
  int? id;

  String? knownForDepartment;
  String? profilePath;
  double? popularity;
  String? mediaType;

  Results(
      {this.adult,
      this.gender,
      this.name,
      this.id,
      this.knownForDepartment,
      this.profilePath,
      this.popularity,
      this.mediaType});

  Results.fromJson(Map<String, dynamic> json) {
    adult = json['adult'];
    gender = json['gender'];
    name = json['name'];
    id = json['id'];

    knownForDepartment = json['known_for_department'];
    profilePath = json['profile_path'];
    popularity = json['popularity'];
    mediaType = json['media_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['adult'] = adult;
    data['gender'] = gender;
    data['name'] = name;
    data['id'] = id;

    data['known_for_department'] = knownForDepartment;
    data['profile_path'] = profilePath;
    data['popularity'] = popularity;
    data['media_type'] = mediaType;
    return data;
  }
}
