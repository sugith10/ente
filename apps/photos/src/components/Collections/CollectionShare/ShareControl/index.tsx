import React, { useEffect, useState } from 'react';
import { Collection, PublicURL } from 'types/collection';
import { appendCollectionKeyToShareURL } from 'utils/collection';
import ManageAddViewer from '../ShareControl/ManageAddViewer';
import ManageAddCollab from './MangeAddCollab';
import ManageParticipants from './ManageParticipants';

export default function ShareControl({
    collection,
    onRootClose,
}: {
    collection: Collection;
    onRootClose: () => void;
}) {
    const [publicShareUrl, setPublicShareUrl] = useState<string>(null);
    const [publicShareProp, setPublicShareProp] = useState<PublicURL>(null);

    useEffect(() => {
        if (collection.publicURLs?.length) {
            setPublicShareProp(collection.publicURLs[0]);
        }
    }, [collection]);

    useEffect(() => {
        if (publicShareProp) {
            const url = appendCollectionKeyToShareURL(
                publicShareProp.url,
                collection.key
            );
            setPublicShareUrl(url);
        } else {
            setPublicShareUrl(null);
        }
    }, [publicShareProp]);

    return (
        <>
            {collection.sharees.length > 0 ? (
                <ManageParticipants
                    publicShareProp={publicShareProp}
                    setPublicShareProp={setPublicShareProp}
                    collection={collection}
                    publicShareUrl={publicShareUrl}
                    onRootClose={onRootClose}
                />
            ) : null}
            <ManageAddViewer
                publicShareProp={publicShareProp}
                setPublicShareProp={setPublicShareProp}
                collection={collection}
                publicShareUrl={publicShareUrl}
                onRootClose={onRootClose}
            />

            <ManageAddCollab
                publicShareProp={publicShareProp}
                setPublicShareProp={setPublicShareProp}
                collection={collection}
                publicShareUrl={publicShareUrl}
                onRootClose={onRootClose}
            />
        </>
    );
}
