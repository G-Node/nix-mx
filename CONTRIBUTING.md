How to contribute to nix-mx
===========================

This document gives some information about how to contribute to the nix-mx project.


Contributing
------------

If you want to contribute to the project please first create a fork of the repository on GitHub.
When you are done with implementing a new feature or with fixing a bug, please send
us a pull request.

If you contribute to the project regularly, it would be very much appreciated if you
would stick to the following development workflow:

1. Select an *issue* from the issue tracker that you want to work on and assign the issue to your account.
   If the *issue* is about a relatively complex matter or requires larger API changes the description of the
   *issue* or its respective discussion should contain a brief concept about how the solution will look like.

2. During the implementation of the feature or bug-fix add your changes in small atomic commits.
   Commit messages should be short but expressive.
   The first line of the message should not exceed **50** characters and the 2nd line should be empty.
   If you want to add further text you can do so from the 3rd line on without limitations.
   If possible reference fixed issues in the commit message (e.g. "fixes #101").

3. When done with the implementation, compile and test the code.
   If your work includes a new function or class please write a small unit test for it.

4. Send us a pull request with your changes.
   The pull request message should explain the changes and reference the *issue* addressed by your code.
   Your pull request will be reviewed by one of our team members.
   Pull requests should never be merged by the author of the contribution, but by another team member.


The issue tracker
-----------------

Please try to avoid duplicates of issues. If you encounter duplicated issues, please close all of them except
one, reference the closed issues in the one that is left open and add missing information from the closed issues
(if necessary) to the remaining issue.

Assign meaningful tags to newly crated issues and if possible assign them to a milestone.


Reviewing pull requests
-----------------------

Every code (even small contributions from core developers) should be added to the project via pull requests.
Each pull request that passes all builds and tests should be reviewed by at least one of the core developers.
If a contribution is rather complex or leads to significant API changes, the respective pull request should be
reviewed by two other developers.
In such cases the first reviewer or the contributor should request a second review in a comment.


Testing
-------

- Unit test can be found in the `tests` sub directory.
- Provide a unit test for every class, method or function.
- Please make sure that all tests pass before merging/sending pull requests.


Style guide
-----------

Adhere to the [MATLAB Style Guidelines 2.0](https://de.mathworks.com/matlabcentral/fileexchange/46056-matlab-style-guidelines-2-0) 
as suggested by Richard Johnson.

Furthermore, adhere to these additional guidelines for the nix-mx project:
- Keep line length at a maximum of 90 characters.
- Use `r` as return variable name of simple (2-3 line) functions.
- Always terminate proper statements with a semicolon.
- Never terminate control structures with a semicolon.
- Structure names should start with a capital letter.
- Structure field names should be camel case and start with a lower case letter.
