"""Repository layer.

Reserved for the data-access contracts introduced with the database step.
Every repository will be a Protocol/ABC so services can depend on an interface
and the FastAPI app can be wired with a mock implementation in tests.
"""
