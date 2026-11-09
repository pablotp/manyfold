module CollectionsHelper
  # Breadcrumb entries for the parent collections ("folder path") of a collection,
  # outermost first. Skips parents the current user can't see and guards against loops.
  def collection_ancestor_breadcrumbs(collection, max_depth: 10)
    ancestors = []
    parent = collection.collection
    seen = [collection]
    while parent && seen.exclude?(parent) && seen.length <= max_depth
      seen << parent
      ancestors.unshift(parent) if policy(parent).show?
      parent = parent.collection
    end
    ancestors.to_h { |ancestor| [ancestor.name, collection_path(ancestor)] }
  end
end
