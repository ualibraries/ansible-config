# ualibraries/ansible-config

This is a neutral place to jot down any major changes that should be
featured into our Ansible setup as we move towards a stable
configurtion management service:

*   We should create a "GLOSSARY.md" document at the root of the
    repository, so that we can clearly define common vocabulary like
    "inventory", "support", "service tag", "environment tag",
    etc. _(mgsimpson, 7/28/2018)_

*   We should think about moving some of the things we're doing in the
    "\_common" role back into the template images in vSphere; I think
    we should still keep those configs in "\_common" so that we can
    use them for monitoring of drift in deployed nodes. _(mgsimpson,
    7/28/2018)_

*   While we're at it, we should replace "openaz-tmpl" with something
    less service-specific, like "ubuntu16-tmpl" or some such --
    there's nothing particularly specialized about the "openaz-tmpl"
    template. _(mgsimpson, 7/28/2018)_

*   We need to flip ansible-admin's deploy key in the Github repo
    from read/write to read-only. _(mgsimpson, 7/28/2018)_

*   _More things here..._

Please try to follow the format of the existing entries when adding
new ones.
