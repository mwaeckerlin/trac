Docker Image for Trac Project Management and Issue Tracking
===========================================================

Run
---

    docker run -p 8080:8080 -it --rm --name trac mwaeckerlin/trac
    
Open `http://localhost:8080` in your browser.


Create Project
--------------

Run `new-project <name> [<description> [<database>]]` in the container, e.g.:

    docker exec -it trac new-project test "Test Project"


More Plattforms
---------------

Instead of using latest Ubuntu on amd64, you may specify another os version and another hardware at the image build, e.g. build for Ubuntu bionic on i386 architecture:

    git clone https://github.com/mwaeckerlin/trac
    cd trac
    docker build --build-arg version=bionic --build-arg arch=i386 --rm --force-rm -t mwaeckerlin/trac .
