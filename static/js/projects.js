var url = "https://api.gopilot.org/events/"+PILOT_EVENT_ID+"/projects";

angular.module('PilotProjects', [])
.controller('ProjectsController', function($scope, $http) {
    $scope.projects = [];
    $scope.modalShown = false;
    $scope.currentProject = {};

    $scope.openProject = function(project){
        $scope.currentProject = project;
        $scope.modalShown = true;
    }

    $http.get("https://api.gopilot.org/events/"+PILOT_EVENT_ID+"/projects")
    .success(function(data){
        data.forEach(function(project){
            if(project.name){
                project.authors = project.team.map(function(user){
                    return user.name;
                });
                var last = project.authors.pop();
                project.authors = project.authors.join(', ') + (project.authors.length > 2 ? ',' : '') + " and " + last;
                $scope.projects.push(project);
            }
        });
    });
})