"""API layer: versioned router plus one module per feature route group.

Future route modules (auth, documents, chat, quiz, recommendations) are
registered here and nowhere else, so the URL map stays easy to audit.
"""
