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
        return [b]
    

def signal_role(role, rawtext, text, lineno, inliner, options={}, content=[]):
    return [signal(signal=text)], []

def html_visit_signal(self, node):

    self.body.append('<b>%s</b>' % node['signal'])
    raise nodes.SkipNode    

def latex_visit_signal(self, node):
    self.body.append(r"\textbf{%s}" % node['signal'])
    raise nodes.SkipNode    


class desig(nodes.Inline, nodes.TextElement):
    pass

def visit_desig_node(self, node):
    pass


class DesigDirective(Directive):
    has_content = True

    def run(self):
        b = desig('')
        return [b]
    

def desig_role(role, rawtext, text, lineno, inliner, options={}, content=[]):
    return [desig(desig=text)], []

def html_visit_desig(self, node):

    self.body.append('<b>%s</b>' % node['desig'])
    raise nodes.SkipNode    

def latex_visit_desig(self, node):
    self.body.append(r"\textbf{%s}" % node['desig'])
    raise nodes.SkipNode    





class part(nodes.Inline, nodes.TextElement):
    pass

def visit_part_node(self, node):
    pass


class PartDirective(Directive):
    has_content = True

    def run(self):
        b = part('')
        #b['citation'] = self.content
        
        return [b]
    

def part_role(role, rawtext, text, lineno, inliner, options={}, content=[]):
    return [part(part=text)], []

def html_visit_part(self, node):

    self.body.append('<b>%s</b>' % node['part'])
    raise nodes.SkipNode    

def latex_visit_part(self, node):
    self.body.append(r"\textbf{%s}" % node['part'])
    raise nodes.SkipNode    


class pm(nodes.Inline, nodes.TextElement):
    pass

def visit_pm_node(self, node):
    pass


class PmDirective(Directive):
    has_content = True

    def run(self):
        b = pm('')
        return [b]
    

def pm_role(role, rawtext, text, lineno, inliner, options={}, content=[]):
    return [pm(pm=text)], []

def html_visit_pm(self, node):

    self.body.append('<b>%s</b>' % node['pm'])
    raise nodes.SkipNode    

def latex_visit_pm(self, node):
    self.body.append("TEST")
    raise nodes.SkipNode    


def setup(app):
    app.add_node(signal,
                 latex=(latex_visit_signal, None), 
                 latexnaked=(latex_visit_signal, None), 
                 html=(html_visit_signal, None))

    app.add_role('signal', signal_role)
    

    app.add_node(desig,
                 latex=(latex_visit_desig, None), 
                 latexnaked=(latex_visit_desig, None), 
                 html=(html_visit_desig, None))

    app.add_role('desig', desig_role)
    

    app.add_node(part,
                 latex=(latex_visit_part, None), 
                 latexnaked=(latex_visit_part, None), 
                 html=(html_visit_part, None))

    app.add_role('part', part_role)
    

