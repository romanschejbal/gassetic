Livereload port and parameters
================================

## Livereload port
There is two way to change the livereload port:

### Command-line argument
```sh
gassetic --port=5555
```

Will use the 5555 port for livereload (usefull if several developers works on the same server)


### Configuration
You can set the port directly in the configuration file

```yml
# gassetic.yml
requires:
    less: gulp-less
    # ...

mimetypes:
    css:
        # ...

livereload:
    port: 1234
```


## Livereload options
You can set all livereload parameters like this:

```yml
# gassetic.yml
requires:
    less: gulp-less
    # ...

mimetypes:
    css:
        # ...

livereload:
    port: 1234
    options:
        silent: false
        key: "/path/to/your/ssl.key" # Those file must be readable by the current user
        cert: "/path/to/your/ssl.crt"
```
