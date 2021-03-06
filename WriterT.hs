{-# LANGUAGE MultiParamTypeClasses, FunctionalDependencies ,FlexibleInstances #-}
module WriterT where

import Control.Monad
import Data.Monoid

newtype MyWriterT w m a = MyWriterT {  runMyWriterT :: m (a,w)  }

class MonadTrans t where
        lift :: Monad m => m a -> t m a

class (Monoid w, Monad m) => (MonadWriter w m) where
        tell :: (Monoid w, Monad m) => w -> m ()

instance (Monoid w, Monad m) => Functor (MyWriterT w m) where
        fmap = liftM

instance (Monoid w, Monad m) => Applicative (MyWriterT w m) where
        pure a = MyWriterT $ pure (a,mempty)
        (<*>)  = ap

instance (Monoid w, Monad m) => Monad (MyWriterT w m) where
        return = pure
        (>>=) m k = MyWriterT $ do
                (a, w) <- runMyWriterT m
                (a',w') <- runMyWriterT (k a)
                return (a',w `mappend` w')

instance (Monoid w) => MonadTrans (MyWriterT w) where
        lift = MyWriterT . liftM (\ x -> (x,mempty))

instance (Monoid w, Monad m) => MonadWriter w (MyWriterT w m) where
        tell w = MyWriterT $ return ((),w)
