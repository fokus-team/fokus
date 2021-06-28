# Bloc Extensions

Collection of Bloc library extensions implementing commonly used patterns

Currently there are two extensions available for both [Cubit] and [Bloc]:
- [ReloadableBloc] that automatically triggers state reloading
- [StatefulBloc] that simplifies common state transitions

Since one of them triggers operations and the other controls them they can
be used together as well as separately to provide the needed functionality.
