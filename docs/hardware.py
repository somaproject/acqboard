from docutils import nodes
import pickle
from sphinx import directives
import os
from subprocess import Popen
from sphinx.util import ensuredir
from sphinx.util.compat import Directive

class signal(nodes.Inline, nodes.TextElement):
    pass

def visit_signal_node(self, node):
    pass


class SignalDirective(Directive):
    has_content = True

    def run(self):
        b = signal('')
        #b['citation'] = self.content
        
        return [b]
    

def signal_role(role, rawtext, text, lineno, inliner, options={}, content=[]):
    return [signal(signal=text)], []

def html_visit_signal(self, node):

    self.body.append('<b>%s</b>' % node['signal'])
    raise nodes.SkipNode    

def latex_visit_signal(self, node):
    self.body.append(r"\textbf{%s}" % node['signal'])
    raise nodes.SkipNode    

def setup(app):
    app.connect('doctree-resolved', process_nodes)

    app.add_node(signal,
                 latex=(latex_visit_signal, None), 
                 latexnaked=(latex_visit_signal, None), 
                 html=(html_visit_signal, None))

    app.add_role('signal', signal_role)
    

def process_nodes(app, doctree, fromdocname):
    pass
