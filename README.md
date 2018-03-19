
# MVVMCKit

MVVMCKit is a combination code/documentation project for building Cocoa
applications using **Model-View-ViewModel-Coordinator**, [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift) and
[ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa).

By explaining rationale, documenting best practices, and providing reusable
library components, we want to make MVVM-C in Swift appealing and easy.

## Model-View-ViewModel

Most Cocoa developers are familiar with the
[Model-View-Controller](http://en.wikipedia.org/wiki/Model-View-Controller)
(MVC) pattern.

In the MVC world, each of the component's resposibilities are as follows:

- Model: Data Container. Data can be read from a Service(eg: Network API) or a Persist Data Store(eg: CoreData) and the written(update) operations are mostly triggered by users via Controller.
- View: Host the view components. It may contain layout logic for it's subviews and animation code.
- Controller: Holds both view and model. It knows business logic, layout logic, navigation logic, presentation logic(optional, converting model data into view friendly format), animation and styling(color, font size and etc) for views.

**[Model-View-ViewModel](http://en.wikipedia.org/wiki/Model-View-ViewModel)
(MVVM)** is another architectural paradigm for GUI applications.

In the MVVM world, model and view remain the same but two logics are shifted from controller to view model to reduce the complexitly of controller:

- Model: Data Container
- View/Controller: Holds both view and view model. Layout logic and navigation logic both reside here.
- View Model: Knows model and is responsible for update data model. Handles business logic and presentation logic(optional, converting model data into view friendly format)

## Coordinator

Coordinator pattern is here to solve complicated navigation logic in MVVM (especially in a large project).

In the MVVM world, in order to navigate from one (view) controller to another, the originated controller needs to know the target view controller.
Moreover, the originated controller needs to populate the view model for the target view controller as well. If a project has a complicated naviagation logic, the view contorller can get pretty messy.

For example, in a shopping cart page, a user can choose to

1. continue to checkout
2. add/update a new payment method
3. add/update a new shipping address

Let's say each of the aforementioned actions needs to be done in a separated page, now the shopping cart page needs to know other three view contollers and their view models! Hence we need coordinator to take away the navigation flow responsibility from controller.

In short, coordinator does two things, manage the navigation flow and populate MVVM stack.
