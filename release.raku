use JSON::Fast;

sub MAIN() {
    given from-json(slurp('META6.json')) -> (:$version!, *%) {
        shell("fez upload");
        tag("release-$version");
    }
}

sub tag($tag) {
    shell "git tag -a -m '$tag' $tag && git push --tags origin"
}
