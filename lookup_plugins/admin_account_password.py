from __future__ import annotations

DOCUMENTATION = """
    name: admin_account_password
    version_added: "2.0"
"""

EXAMPLES = """
"""

RETURN = """
_raw:
  description:
    - a password
  type: list
  elements: str
"""

from ansible.plugins.lookup import LookupBase
from ansible.plugins.loader import lookup_loader

class LookupModule(LookupBase):

    def run(self, terms, variables=None, **kwargs):
        self.set_options(var_options=variables, direct=kwargs)

        return lookup_loader.get('ansible.builtin.password', loader=self._loader, templar=self._templar).run(terms, variables=None, chars=['ascii_letters', 'digits', '-'], length=16)