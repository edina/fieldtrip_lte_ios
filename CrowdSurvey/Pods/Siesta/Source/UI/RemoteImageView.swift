//
//  RemoteImageView.swift
//  Siesta
//
//  Created by Paul on 2015/8/26.
//  Copyright © 2015 Bust Out Solutions. All rights reserved.
//


/**
  A `UIImageView` that asynchronously loads and displays remote images.
*/
public class RemoteImageView: UIImageView
    {
    /// Optional view to show while image is loading.
    @IBOutlet public weak var loadingView: UIView?

    /// Optional view to show if image is unavailable. Not shown while image is loading.
    @IBOutlet public weak var alternateView: UIView?

    /// Optional image to show if image is either unavailable or loading. Suppresses alternateView if non-nil.
    @IBOutlet public var placeholderImage: UIImage?

    /// The default service to cache `RemoteImageView` images.
    public static var defaultImageService: Service = Service()

    /// The service this view should use to request & cache its images.
    public var imageService: Service = RemoteImageView.defaultImageService

    /// A URL whose content is the image to display in this view.
    public var imageURL: String?
        {
        get { return imageResource?.url.absoluteString }
        set { imageResource = imageService.resource(absoluteURL: newValue) }
        }

    /**
      A remote resource whose content is the image to display in this view.

      If this image is already in memory, it is displayed synchronously (no flicker!). If the image is missing or
      potentially stale, setting this property triggers a load.
    */
    public var imageResource: Resource?
        {
        willSet
            {
            imageResource?.removeObservers(ownedBy: self)
            imageResource?.cancelLoadIfUnobserved(afterDelay: 0.05)
            }

        didSet
            {
            imageResource?.loadIfNeeded()
            imageResource?.addObserver(owner: self)
                { [weak self] _ in self?.updateViews() }

            if imageResource == nil  // (and thus closure above was not called on ObserverAdded)
                { updateViews() }
            }
        }

    private func updateViews()
        {
        image = imageResource?.typedContent(ifNone: placeholderImage)

        let isLoading = imageResource?.isLoading ?? false
        loadingView?.hidden = !isLoading
        alternateView?.hidden = (image != nil) || isLoading
        }
    }
