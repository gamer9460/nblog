# pacenthink.io

A repository to house the code for https://www.pacenthink.io/

## Initial Setup 

This repository was bootstrapped using the [Hugo QuickStart Guide](https://gohugo.io/getting-started/quick-start/).

## Test

Use the steps below to test your changes:

**Step 1**. Add a new blog file: `hugo new content/blog/<topic>.md` 

**Step 2**. Edit the newly created file with the desired change/s.

**Step 3**. Build Hugo Docker image locally: `make build`. 

**Step 4**. Run Hugo locally to validate your change/s: `make deploy`. 

**Step 5**. Navigate to http://localhost:8080 to view your changes. 

**Step 6**. [Publish your changes](#contributions).

**Helpful hint**: The project includes a [Makefile](https://github.com/pacenthink/pacenthink.io/Makefile) to help you speed up testing. Run `make help` from the root of the project or see the makefile for details.

## Assumptions

The repository assumes the following:

- A basic understanding of [Docker](https://docs.docker.com/engine/) with Docker installed locally.
- A basic understanding of [Git](https://git-scm.com/).
- A basic understanding of [Hugo](https://gohugo.io). 
    - **Important Notes**: 
        - This repository uses the following Hugo Theme: https://github.com/adityatelange/hugo-PaperMod.git
        - Hugo version `>= v0.100.2`. 

## Contributions

Contributions are always welcome. As such, this project uses the `main` branch as the source of truth to track and publish changes.

To publish a change, create a [PR](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) by following the steps below: 

**Step 1**. Clone this project: `git@github.com:pacenthink/pacenthink.io.git`.

**Step 2**. Pull hugo theme from submodule if missing `git submodule update --init --recursive`

**Step 3**. Checkout a branch:
```sh 
# Feature branch
$ git checkout -b feature/abc

# Bug fix branch
$ git checkout -b fix/abc
```

**Step 4**. Validate the changes locally by executing the steps defined under [Test](#test).

**Step 5**. Commit and push the new changes to the remote:
```
$ git add file1 file2 ...

$ git commit -m "Adding some change"

$ git push --set-upstream origin <branch>
```

**Step 6**. Create a PR against the `main` branch and assign it to a team member for review.

**Step 7**. Once merged, a CI/CD pipeline will run on the `main` branch to publish the change/s via the [BND Platform](https://bnd.pacenthink.co/login).

**Step 8**. Verify that your change has been propagated correctly by visiting https://wwww.pacenthink.io/

    
